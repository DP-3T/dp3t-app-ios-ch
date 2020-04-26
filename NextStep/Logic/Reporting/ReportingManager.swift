///

#if CALIBRATION_SDK
    import DP3TSDK_CALIBRATION
#else
    import DP3TSDK
#endif

import Foundation

class ReportingManager {
    // MARK: - Shared

    static let shared = ReportingManager()

    // MARK: - Init

    private init() {}

    // MARK: - Variables

    enum ReportingError: Error {
        case network
        case unexpected
        case invalidCode
    }

    // in memory dictionary for codes we already have a token and date,
    // if only the second request (iWasExposed) fails
    private var codeDictionary: [String: (String, Date)] = [:]

    let codeValidator = CodeValidator()

    // MARK: - API

    func report(covidCode: String, completion: @escaping (ReportingError?) -> Void) {
        if let tokenDate = codeDictionary[covidCode] {
            // only second part needed
            sendIWasExposed(token: tokenDate.0, date: tokenDate.1, completion: completion)
        } else {
            // get token and date first
            codeValidator.sendCodeRequest(code: covidCode) { [weak self] result in
                guard let strongSelf = self else { return }

                switch result {
                case let .success(token: token, date: date):
                    // save in code dictionary
                    strongSelf.codeDictionary[covidCode] = (token, date)

                    // second part
                    strongSelf.sendIWasExposed(token: token, date: date, completion: completion)
                case .networkError:
                    completion(.network)
                case .unexpectedError:
                    completion(.unexpected)
                case .invalidTokenError:
                    completion(.invalidCode)
                }
            }
        }
    }

    // MARK: - Second part: I was exposed

    private func sendIWasExposed(token: String, date: Date, completion: @escaping (ReportingError?) -> Void) {
        DP3TTracing.iWasExposed(onset: date, authentication: .HTTPAuthorizationBearer(token: token)) { result in
            DispatchQueue.main.async {
                print(result)
                switch result {
                case .success:
                    TracingManager.shared.updateStatus { error in
                        if error != nil {
                            completion(.unexpected)
                        } else {
                            completion(nil)
                        }
                    }
                case .failure(.networkingError(error: _)):
                    completion(.network)
                case .failure:
                    completion(.unexpected)
                }
            }
        }
    }
}
