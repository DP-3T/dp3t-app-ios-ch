/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import Foundation

import DP3TSDK

/// Implementation of business rules to link SDK and all errors and states  to UI state
class StateLogic {
    let manager: StateManager

    init(manager: StateManager) {
        self.manager = manager
    }

    func buildState() -> StateModel {
        // Default state = active tracing, no errors or warnings
        var newState = StateModel()
        var tracing: StateModel.TracingState = .tracingActive

        // Check errors
        setErrorStates(&newState, tracing: &tracing)

        // Set tracing active
        newState.begegnungenDetail.tracingEnabled = TracingManager.shared.isActivated
        newState.begegnungenDetail.tracing = tracing

        // Get state of SDK tracing
        guard let tracingState = manager.tracingState else {
            assertionFailure("Tracing manager state should always be loaded before UI")
            return newState
        }

        // Update homescreen UI
        setHomescreenState(&newState, tracing: tracing)
        setInfoBoxState(&newState)

        //
        // Detect exposure, infection
        //

        var infectionStatus = tracingState.infectionStatus
        #if ENABLE_TESTING
        setDebugOverwrite(&infectionStatus, &newState)
        #endif

        switch infectionStatus {
        case .healthy:
            break

        case .infected:
            setInfectedState(&newState)

        case let .exposed(days):
            setExposedState(&newState, days: days)
            setLastMeldungState(&newState)
        }

        // Set debug helpers
        #if ENABLE_TESTING
            setDebugMeldungen(&newState)
            setDebugDisplayValues(&newState, tracingState: tracingState)
            setDebugLog(&newState)
        #endif

        return newState
    }

    private func setErrorStates(_: inout StateModel, tracing: inout StateModel.TracingState) {
        switch manager.trackingState {
        case let .inactive(error):
            switch error {
            case .bluetoothTurnedOff:
                tracing = .bluetoothTurnedOff
            case .permissonError:
                tracing = .tracingPermissionError
            case .databaseError:
                tracing = .unexpectedError(code: error.errorCodeString)
            case .exposureNotificationError:
                tracing = .tracingPermissionError
            case .networkingError, .caseSynchronizationError, .userAlreadyMarkedAsInfected:
                // TODO: Something
                break // networkingError should already be handled elsewhere, ignore caseSynchronizationError for now
            }
        case .stopped:
            tracing = .tracingDisabled
        case .active:
            // skd says tracking works.

            // other checks, maybe not needed
            if manager.anyError != nil || !manager.tracingIsActivated {
                tracing = manager.hasTimeInconsistencyError ? .timeInconsistencyError : .tracingDisabled
            }
        }
    }

    private func setHomescreenState(_ newState: inout StateModel, tracing: StateModel.TracingState) {
        newState.homescreen.header = tracing
        newState.homescreen.begegnungen = tracing

        newState.homescreen.meldungen.pushProblem = !manager.pushOk

        if let st = manager.tracingState {
            newState.homescreen.meldungen.backgroundUpdateProblem = st.backgroundRefreshState != .available
        }

        if manager.immediatelyShowSyncError {
            newState.homescreen.meldungen.syncProblemOtherError = true
            if let codedError = StateManager.shared.syncError as? CodedError {
                newState.homescreen.meldungen.errorCode = codedError.errorCodeString
            }
        }

        if let first = manager.firstSyncErrorTime,
            let last = manager.lastSyncErrorTime,
            last.timeIntervalSince(first) > manager.syncProblemInterval {
            newState.homescreen.meldungen.syncProblemNetworkingError = true
            if let codedError = StateManager.shared.syncError as? CodedError {
                newState.homescreen.meldungen.errorCode = codedError.errorCodeString
            }
        }
    }

    private func setInfoBoxState(_ newState: inout StateModel) {
        if let localizedInfoBox = ConfigManager.currentConfig?.infoBox {
            let infoBox: ConfigResponseBody.LocalizedInfobox.InfoBox
            switch Language.current {
            case .german:
                infoBox = localizedInfoBox.deInfoBox
            case .italian:
                infoBox = localizedInfoBox.itInfoBox
            case .english:
                infoBox = localizedInfoBox.enInfoBox
            case .france:
                infoBox = localizedInfoBox.frInfoBox
            }
            newState.homescreen.infoBox = StateModel.Homescreen.InfoBox(title: infoBox.title,
                                                                                      text: infoBox.msg,
                                                                                      link: infoBox.urlTitle,
                                                                                      url: infoBox.url)
        }
    }

    // MARK: - Set global state to infected or exposed

    private func setInfectedState(_ newState: inout StateModel) {
        newState.homescreen.meldungen.meldung = .infected
        newState.meldungenDetail.meldung = .infected
        newState.homescreen.header = .tracingEnded
        newState.homescreen.begegnungen = .tracingEnded
    }

    private func setExposedState(_ newState: inout StateModel, days: [ExposureDay]) {
        newState.homescreen.meldungen.meldung = .exposed
        newState.meldungenDetail.meldung = .exposed

        newState.meldungenDetail.meldungen = days.map { (mc) -> StateModel.MeldungenDetail.NSMeldungModel in StateModel.MeldungenDetail.NSMeldungModel(identifier: mc.identifier, timestamp: mc.exposedDate)
        }.sorted(by: { (a, b) -> Bool in
            a.timestamp < b.timestamp
        })
    }

    private func setLastMeldungState(_ newState: inout StateModel) {
        if let meldung = newState.meldungenDetail.meldungen.last {
            newState.shouldStartAtMeldungenDetail = UserStorage.shared.lastPhoneCall(for: meldung.identifier) == nil
            newState.homescreen.meldungen.lastMeldung = meldung.timestamp
            newState.meldungenDetail.showMeldungWithAnimation = !UserStorage.shared.hasSeenMessage(for: meldung.identifier)

            if let lastPhoneCall = UserStorage.shared.lastPhoneCallDate {
                if lastPhoneCall > meldung.timestamp {
                    newState.meldungenDetail.phoneCallState = .calledAfterLastExposure
                } else {
                    newState.meldungenDetail.phoneCallState = newState.meldungenDetail.meldungen.count > 1
                        ? .multipleExposuresNotCalled : .notCalled
                }
            } else {
                newState.meldungenDetail.phoneCallState = .notCalled
            }
        }
    }

    #if ENABLE_TESTING

        // MARK: - DEBUG Helpers

        private func setDebugOverwrite(_ infectionStatus: inout InfectionStatus, _ newState: inout StateModel) {
            if let os = manager.overwrittenInfectionState {
                switch os {
                case .infected:
                    infectionStatus = .infected
                case .exposed:
                    infectionStatus = .exposed(days: [])
                case .healthy:
                    infectionStatus = .healthy
                }

                newState.debug.overwrittenInfectionState = os
            }
        }

        static let randIdentifier1 = UUID()
        static let randIdentifier2 = UUID()
    static let randDate1 = Date(timeIntervalSinceNow: -10000)
    static let randDate2 = Date(timeIntervalSinceNow: -100000)

        private func setDebugMeldungen(_ newState: inout StateModel) {
            // in case the infection state is overwritten, we need to
            // add at least one meldung
            if let os = manager.overwrittenInfectionState, os == .exposed {
                newState.meldungenDetail.meldungen = [StateModel.MeldungenDetail.NSMeldungModel(identifier: Self.randIdentifier1, timestamp: Self.randDate1), StateModel.MeldungenDetail.NSMeldungModel(identifier: Self.randIdentifier2, timestamp: Self.randDate2)].sorted(by: { (a, b) -> Bool in
                    a.timestamp < b.timestamp
                })
                newState.shouldStartAtMeldungenDetail = true
                newState.meldungenDetail.showMeldungWithAnimation = true

                setLastMeldungState(&newState)
            }
        }

        private func setDebugDisplayValues(_ newState: inout StateModel, tracingState: TracingState) {
            newState.debug.lastSync = tracingState.lastSync

            // add real tracing state of sdk and overwritten state
            switch tracingState.infectionStatus {
            case .healthy:
                newState.debug.infectionStatus = .healthy
            case .exposed:
                newState.debug.infectionStatus = .exposed
            case .infected:
                newState.debug.infectionStatus = .infected
            }
        }

    private func setDebugLog(_ newState: inout StateModel) {
        let logs = Logger.lastLogs
        let df = DateFormatter()
        df.dateFormat = "dd.MM, HH:mm"
        let attr = NSMutableAttributedString()
        logs.forEach { (date, log)  in
            let s1 = NSAttributedString(string: df.string(from: date), attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
            let s2 = NSAttributedString(string: " ")
            let s3 = NSAttributedString(string: log, attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            let s4 = NSAttributedString(string: "\n")
            attr.append(s1)
            attr.append(s2)
            attr.append(s3)
            attr.append(s4)
        }
        newState.debug.logOutput = attr
    }

    #endif
}
