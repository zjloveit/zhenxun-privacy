import AppTrackingTransparency
import Foundation

enum AdPlacement: String {
    case home
    case eventList
    case settings
}

enum AdConfig {
    static let adsEnabled = true

    private static let appID = "ca-app-pub-4080585949658920~5985491861"
    private static let bannerHome = "ca-app-pub-4080585949658920/9909944913"
    private static let bannerEventList = "ca-app-pub-4080585949658920/9909944913"
    private static let bannerSettings = "ca-app-pub-4080585949658920/9909944913"

    static var applicationID: String { appID }

    static func bannerUnitID(for placement: AdPlacement) -> String {
        switch placement {
        case .home: return bannerHome
        case .eventList: return bannerEventList
        case .settings: return bannerSettings
        }
    }

    static func requestTrackingAuthorizationIfNeeded() {
        guard adsEnabled else { return }
        guard #available(iOS 14, *) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
}
