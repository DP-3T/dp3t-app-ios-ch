/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import DP3TSDK
import ExposureNotification
import Foundation
import UserNotifications

protocol UserNotificationCenter {
    var delegate: UNUserNotificationCenterDelegate? { get set }
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func removeAllDeliveredNotifications()
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
}

extension UNUserNotificationCenter: UserNotificationCenter {}

/// Helper to show a local push notification when the state of the user changes from not-exposed to exposed
class NSLocalPush: NSObject, LocalPushProtocol {
    static let shared = NSLocalPush()

    private var center: UserNotificationCenter

    enum Identifiers: String, CaseIterable, Codable {
        // Exposure Notifications
        case bluetoothError = "ch.admin.bag.notification.bluetooth.warning"
        case permissionError = "ch.admin.bag.notification.permission.warning"

        case syncWarning1 = "ch.admin.bag.notification.syncWarning1"
        case syncWarning2 = "ch.admin.bag.notification.syncWarning2"

        case syncError = "ch.admin.bag.notification.syncError"

        case tracingReminder = "ch.admin.bag.notification.tracing.reminder"

        // CheckIn
        case checkInReminder = "ch.admin.bag.dp3t.notificationtype.reminder"
        case checkInautomaticReminder = "ch.admin.bag.dp3t.notificationtype.automaticReminder"
        case checkInautomaticCheckout = "ch.admin.bag.dp3t.notificationtype.automaticCheckout"
        case checkInExposure = "ch.admin.bag.dp3t.notificationtype.exposure"
        case checkInbackgroundTaskWarningTrigger = "ch.admin.bag.dp3t.notificationtype.backgroundtaskwarning"

        var isErrorNotification: Bool {
            switch self {
            case .bluetoothError, .permissionError:
                return true
            default:
                return false
            }
        }
    }

    var applicationState: UIApplication.State {
        UIApplication.shared.applicationState
    }

    init(notificationCenter: UserNotificationCenter = UNUserNotificationCenter.current(), keychain: KeychainProtocol = Keychain()) {
        center = notificationCenter
        _exposureIdentifiers.keychain = keychain
        _scheduledErrorIdentifiers.keychain = keychain
        _lastestExposureDate.keychain = keychain
        super.init()
        center.delegate = self
    }

    func scheduleExposureNotificationsIfNeeded(provider: ExposureProvider) {
        // sort the exposures from newset to oldest
        if let exposures = provider.exposures?.sorted(by: >) {
            for exposure in exposures {
                // check if the exposure is new and if the latesExposureDate is prior to the new Exposure
                // we only schedule the notification in these cases
                if !exposureIdentifiers.contains(exposure.identifier), (lastestExposureDate ?? .distantPast) < exposure.date {
                    // we schedule the notification
                    scheduleNotification(identifier: exposure.identifier)
                    // and update the latestExpsoureDate
                    lastestExposureDate = exposure.date
                    // and reset the didOpenLeitfaden flag
                    UserStorage.shared.didOpenLeitfaden = false

                    break
                }
            }
            // store all new identifiers
            exposureIdentifiers = exposures.map(\.identifier)
        }
    }

    func clearNotifications() {
        center.removeAllDeliveredNotifications()

        var allIdentifier = [String]()
        for identifier in exposureIdentifiers {
            allIdentifier.append(identifier)
            for delayIndex in 1 ... 12 {
                allIdentifier.append(identifier + "\(delayIndex)")
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: allIdentifier)
    }

    var now: Date {
        .init()
    }

    @KeychainPersisted(key: "lastestExposureDate", defaultValue: nil)
    private var lastestExposureDate: Date?

    @KeychainPersisted(key: "exposureIdentifiers", defaultValue: [])
    private var exposureIdentifiers: [String]

    @KeychainPersisted(key: "scheduledErrorIdentifiers", defaultValue: [])
    private var scheduledErrorIdentifiers: [Identifiers]

    private func scheduleNotification(identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "push_exposed_title".ub_localized
        content.body = "push_exposed_text".ub_localized
        content.sound = .default
        content.threadIdentifier = identifier

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        center.add(request, withCompletionHandler: nil)

        // applicationState can only be accessed from the main thread
        let state: UIApplication.State
        if Thread.isMainThread {
            state = applicationState
        } else {
            state = DispatchQueue.main.sync {
                applicationState
            }
        }

        // only if the app is in the background
        if state == .background {
            // schedule a notification every 4h for the next 2 days
            // so that the user can not miss the notification
            for delayIndex in 1 ... 12 {
                let delay = TimeInterval(delayIndex * 4 * 60 * 60)
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                let request = UNNotificationRequest(identifier: identifier + "\(delayIndex)", content: content, trigger: trigger)
                center.add(request, withCompletionHandler: nil)
            }
        }
    }

    private func alreadyShowsReport() -> Bool {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.navigationController.viewControllers.last is NSReportsDetailViewController {
                return true
            }
        }
        return false
    }

    func jumpToReport(animated: Bool = true) {
        guard !alreadyShowsReport() else {
            return
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Dismiss any modal views (if even present)
            appDelegate.navigationController.dismiss(animated: false)

            // Pop to root view controller
            appDelegate.navigationController.popToRootViewController(animated: false)

            // Reset tab bar back to homescreen tab
            appDelegate.tabBarController.currentTab = .homescreen

            // Present detail from home screen view controller
            appDelegate.tabBarController.homescreen.presentReportsDetail(animated: animated)
        }
    }

    // MARK: - Sync warnings

    // 1: If the background tak doesnt work for 2 days we show a notification
    //    User should open app to fix issues

    private func scheduleSyncWarningNotification(delay: TimeInterval, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "sync_warning_notification_title".ub_localized
        content.body = "sync_warning_notification_text".ub_localized
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    private let timeInterval1: TimeInterval = 60 * 60 * 24 * 2 // Two days
    private let timeInterval2: TimeInterval = 60 * 60 * 24 * 7 // Seven days

    func removeSyncWarningTriggers() {
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.syncWarning1.rawValue,
                                                                   Identifiers.syncWarning2.rawValue,
                                                                   Identifiers.syncError.rawValue])
    }

    // This method gets called everytime we get executed in the backgrund or if the app was launched manually
    func resetBackgroundTaskWarningTriggers() {
        // Adding a request with the same identifier again automatically cancels an existing request with that identifier, if present
        scheduleSyncWarningNotification(delay: timeInterval1, identifier: Identifiers.syncWarning1.rawValue)
        scheduleSyncWarningNotification(delay: timeInterval2, identifier: Identifiers.syncWarning2.rawValue)
    }

    // 1: If a error happens during sync we show a notification after 1 day
    //    we cancel the notification if the error was resolved in the meantime

    private let syncErrorNotificationDelay: TimeInterval = 60 * 60 * 24 * 1 // One day

    func handleSync(result: SyncResult) {
        switch result {
        case .failure:
            scheduleSyncWarningNotification(delay: syncErrorNotificationDelay, identifier: Identifiers.syncError.rawValue)
        case .success:
            center.removePendingNotificationRequests(withIdentifiers: [Identifiers.syncError.rawValue])
        case .skipped:
            break
        }
    }

    func handleTracingState(_ state: DP3TSDK.TrackingState) {
        switch state {
        case .initialization:
            break
        case .active, .stopped:
            resetAllErrorNotifications()
        case let .inactive(error: error):
            switch error {
            case .bluetoothTurnedOff:
                scheduleBluetoothNotification()
            case let .exposureNotificationError(error: error):
                if #available(iOS 12.5, *) {
                    if let error = error as? ENError {
                        handleENError(error)
                    }
                }
            case .permissonError:
                schedulePermissonErrorNotification()
            default:
                break
            }
        }
    }

    private func scheduleBluetoothNotification() {
        scheduleErrorNotification(identifier: .bluetoothError,
                                  title: "bluetooth_turned_off_title".ub_localized,
                                  text: "bluetooth_turned_off_text".ub_localized)
    }

    private func schedulePermissonErrorNotification() {
        scheduleErrorNotification(identifier: .permissionError,
                                  title: "tracing_permission_error_title_ios".ub_localized.replaceSettingsString,
                                  text: "tracing_permission_error_text_ios".ub_localized.replaceSettingsString)
    }

    @available(iOS 12.5, *)
    private func handleENError(_ error: ENError) {
        switch error.code {
        case .bluetoothOff:
            scheduleBluetoothNotification()
        case .notAuthorized, .notEnabled, .restricted:
            schedulePermissonErrorNotification()
        default:
            break
        }
    }

    private func scheduleErrorNotification(identifier: Identifiers, title: String, text: String) {
        guard !scheduledErrorIdentifiers.contains(identifier) else {
            return
        }

        // skip if hour is between 23:00 and 07:00 in order to not schedule notifications during the night
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: now)
        guard let hour = components.hour,
              hour > 7,
              hour < 23 else {
            return
        }

        scheduledErrorIdentifiers.append(identifier)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        // set the notification to trigger in 1 minute since the state could only be temporary
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: identifier.rawValue, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    private func resetAllErrorNotifications() {
        let identifiers = Identifiers.allCases
            .filter { $0.isErrorNotification }
            .map(\.rawValue)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        scheduledErrorIdentifiers.removeAll()
    }

    // MARK: - Tracing Reminder Notifications

    func scheduleReminderNotification(reminder: NSTracingReminderViewController.Reminder) {
        guard reminder != .noReminder, let timeInterval = reminder.duration else {
            resetReminderNotification()
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "tracing_reminder_notification_title".ub_localized
        content.body = "tracing_reminder_notification_subtitle".ub_localized
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: Identifiers.tracingReminder.rawValue, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    func resetReminderNotification() {
        center.removeDeliveredNotifications(withIdentifiers: [Identifiers.tracingReminder.rawValue])
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.tracingReminder.rawValue])
    }

    // MARK: - CheckIn Reminder Notifications

    func removeAllCheckInReminders() {
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.checkInReminder.rawValue,
                                                                   Identifiers.checkInautomaticReminder.rawValue,
                                                                   Identifiers.checkInautomaticCheckout.rawValue])
    }

    func scheduleCheckInReminderNotification(after timeInterval: TimeInterval) {
        let notification = UNMutableNotificationContent()
        notification.categoryIdentifier = Identifiers.checkInReminder.rawValue
        notification.title = "checkout_reminder_title".ub_localized
        notification.body = "checkout_reminder_text".ub_localized
        notification.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        center.add(UNNotificationRequest(identifier: Identifiers.checkInReminder.rawValue, content: notification, trigger: trigger), withCompletionHandler: nil)
    }

    func scheduleAutomaticReminderAndCheckoutNotifications(reminderTimeInterval: TimeInterval? = nil, checkoutTimeInterval: TimeInterval? = nil) {
        // Reminder after 8 hours
        let notification = UNMutableNotificationContent()
        notification.categoryIdentifier = Identifiers.checkInautomaticReminder.rawValue
        notification.title = "checkout_reminder_title".ub_localized
        notification.body = "checkout_reminder_text".ub_localized
        notification.sound = .default

        #if DEBUG
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: .minute * 8, repeats: false)
        #else
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: reminderTimeInterval ?? .hour * 8, repeats: false)
        #endif
        center.add(UNNotificationRequest(identifier: Identifiers.checkInautomaticReminder.rawValue, content: notification, trigger: trigger), withCompletionHandler: nil)

        // Reminder after 12 hours
        let notification2 = UNMutableNotificationContent()
        notification2.categoryIdentifier = Identifiers.checkInautomaticCheckout.rawValue
        notification2.title = "auto_checkout_title".ub_localized
        notification2.body = "auto_checkout_body".ub_localized
        notification2.sound = .default

        #if DEBUG
            let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: .minute * 12, repeats: false)
        #else
            let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: checkoutTimeInterval ?? .hour * 12, repeats: false)
        #endif
        center.add(UNNotificationRequest(identifier: Identifiers.checkInautomaticCheckout.rawValue, content: notification2, trigger: trigger2), withCompletionHandler: nil)
    }

    func showCheckInExposureNotification() {
        let notification = UNMutableNotificationContent()
        notification.categoryIdentifier = Identifiers.checkInExposure.rawValue
        notification.title = "exposure_notification_title".ub_localized
        notification.body = "exposure_notification_body".ub_localized
        notification.sound = .default

        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: notification, trigger: nil), withCompletionHandler: nil)
    }
}

extension NSLocalPush: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if TracingManager.shared.isSupported, alreadyShowsReport(), exposureIdentifiers.contains(notification.request.identifier) {
            completionHandler([])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler _: @escaping () -> Void) {
        if exposureIdentifiers.contains(response.notification.request.identifier),
           response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            jumpToReport()
            return
        }
    }
}
