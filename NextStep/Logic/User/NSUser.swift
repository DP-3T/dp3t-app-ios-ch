/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSUser {
    static let shared = NSUser()

    @UBUserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    var hasCompletedOnboarding: Bool {
        didSet {
            TracingManager.shared.userHasCompletedOnboarding()
        }
    }

    func registerPhoneCall(identifier: Int) {
        var lastPhoneCalls = self.lastPhoneCalls
        // we only want the last
        lastPhoneCalls.removeAll()
        lastPhoneCalls["\(identifier)"] = Date()

        self.lastPhoneCalls = lastPhoneCalls

        UIStateManager.shared.userCalledInfoLine()
    }

    func lastPhoneCall(for identifier: Int) -> Date? {
        if lastPhoneCalls.keys.contains("\(identifier)") {
            return lastPhoneCalls["\(identifier)"]
        }

        return nil
    }

    @UBUserDefault(key: "lastPhoneCalls", defaultValue: [:])
    private var lastPhoneCalls: [String: Date]

    @UBOptionalUserDefault(key: "positiveTestSendDate")
    public var positiveTestSendDate: Date?
}
