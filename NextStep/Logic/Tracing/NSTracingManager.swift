/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import CoreBluetooth
import DP3TSDK_CALIBRATION
import Foundation
import UIKit

/// Glue code between SDK and UI
class NSTracingManager: NSObject {
    /// Identifier known to
    /// https://github.com/DP-3T/dp3t-discovery/blob/master/discovery.json
    let appId = "org.dpppt.demo" // "ch.ubique.nextstep"

    static let shared = NSTracingManager()

    let uiStateManager = NSUIStateManager()

    @UBUserDefault(key: "com.ubique.nextstep.isActivated", defaultValue: true)
    public var isActivated: Bool {
        didSet {
            if isActivated {
                beginUpdatesAndTracing()
            } else {
                endTracing()
            }
            NSUIStateManager.shared.changedTracingActivated()
        }
    }

    private var central: CBCentralManager?

    func initialize() {
        do {
            let bucketBaseUrl = Environment.current.publishService.baseURL
            let reportBaseUrl = Environment.current.configService.baseURL
            let pk = Data(base64Encoded: "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFL1k5eGUwanBOVGNLMXkxMVdpN3NWK0t2Mm5QTwo0d3FqSklRNjZJU05TWXI3THU1am81cVhJQkg0VURRNmFENm9kMExjUXdSRzBwRVgxTUtyMlYrdzRRPT0KLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0t")!
            let descriptor = ApplicationDescriptor(appId: appId, bucketBaseUrl: bucketBaseUrl, reportBaseUrl: reportBaseUrl, jwtPublicKey: pk)
            try DP3TTracing.initialize(with: .manual(descriptor))
        } catch {
            NSUIStateManager.shared.tracingStartError = error
        }

        UIApplication.shared.setMinimumBackgroundFetchInterval(databaseSyncInterval)
    }

    func beginUpdatesAndTracing() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatus), name: UIApplication.willEnterForegroundNotification, object: nil)

        if NSUser.shared.hasCompletedOnboarding, isActivated {
            do {
                try DP3TTracing.startTracing()
                NSUIStateManager.shared.tracingStartError = nil
            } catch {
                NSUIStateManager.shared.tracingStartError = error
            }

            if central == nil {
                central = CBCentralManager(delegate: self, queue: nil)
            }
        }

        updateStatus()
    }

    func endTracing() {
        DP3TTracing.stopTracing()
    }

    func resetSDK() {
        try? DP3TTracing.reset()
        NSUIStateManager.shared.overwrittenInfectionState = nil
    }

    func userHasCompletedOnboarding() {
        do {
            try DP3TTracing.startTracing()
            NSUIStateManager.shared.tracingStartError = nil
        } catch {
            NSUIStateManager.shared.tracingStartError = error
        }

        updateStatus()
    }

    @objc
    private func updateStatus() {
        DP3TTracing.status { result in
            switch result {
            case let .failure(e):
                NSUIStateManager.shared.updateError = e
            case let .success(st):
                NSUIStateManager.shared.updateError = nil
                NSUIStateManager.shared.tracingState = st
                NSUIStateManager.shared.trackingState = st.trackingState

                // schedule local push if exposed
                NSTracingLocalPush.shared.update(state: st)
            }
            DP3TTracing.delegate = self
        }

        syncDatabaseIfNeeded()
    }

    func performFetch(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        syncDatabaseIfNeeded(completionHandler: completionHandler)
    }

    func syncDatabaseIfNeeded(completionHandler: ((UIBackgroundFetchResult) -> Void)? = nil) {
        guard !databaseIsSyncing else {
            completionHandler?(.noData)
            return
        }

        if lastDatabaseSync == nil || -(lastDatabaseSync!.timeIntervalSinceNow) > databaseSyncInterval {
            syncDatabase(completionHandler: completionHandler)
        }
    }

    func forceSyncDatabase() {
        syncDatabase(completionHandler: nil)
    }

    @UBOptionalUserDefault(key: "com.ubique.nextstep.lastDatabaseSync") private var lastDatabaseSync: Date?
    private var databaseIsSyncing = false
    private var databaseSyncInterval: TimeInterval = 10

    private func syncDatabase(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        databaseIsSyncing = true
        let taskIdentifier = UIApplication.shared.beginBackgroundTask {
            // can't stop sync
        }
        DP3TTracing.sync { result in
            switch result {
            case let .failure(e):
                NSUIStateManager.shared.syncError = e
                if case DP3TTracingError.networkingError = e {
                    NSUIStateManager.shared.lastSyncErrorTime = Date()
                }
                completionHandler?(.failed)
            case .success:
                self.lastDatabaseSync = Date()
                NSUIStateManager.shared.firstSyncErrorTime = nil
                NSUIStateManager.shared.lastSyncErrorTime = nil

                self.updateStatus()

                completionHandler?(.newData)
            }
            if taskIdentifier != .invalid {
                UIApplication.shared.endBackgroundTask(taskIdentifier)
            }
            self.databaseIsSyncing = false
        }
    }
}

extension NSTracingManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn, isActivated {
            beginUpdatesAndTracing()
        }
    }
}

extension NSTracingManager: DP3TTracingDelegate {
    func DP3TTracingStateChanged(_ state: TracingState) {
        DispatchQueue.main.async {
            NSUIStateManager.shared.updateError = nil
            NSUIStateManager.shared.tracingState = state
            NSUIStateManager.shared.trackingState = state.trackingState
        }
    }
}
