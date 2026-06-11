import Foundation
import CoreLocation

/// 地震速报 / 目录事件
struct EarthquakeEvent: Identifiable, Codable, Hashable {
    let id: String
    let magnitude: Double
    let latitude: Double
    let longitude: Double
    let depth: Double
    let locationName: String
    let originTime: Date
    let reportType: ReportType
    /// 気象庁震度（例: "3", "5+"）
    let maxShindo: String?

    enum ReportType: String, Codable {
        case automatic
        case reviewed
    }

    init(
        id: String,
        magnitude: Double,
        latitude: Double,
        longitude: Double,
        depth: Double,
        locationName: String,
        originTime: Date,
        reportType: ReportType,
        maxShindo: String? = nil
    ) {
        self.id = id
        self.magnitude = magnitude
        self.latitude = latitude
        self.longitude = longitude
        self.depth = depth
        self.locationName = locationName
        self.originTime = originTime
        self.reportType = reportType
        self.maxShindo = maxShindo
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var magnitudeLabel: String {
        String(format: "%.1f", magnitude)
    }

    var depthLabel: String {
        String(format: "%.0f km", depth)
    }

    var shindoLabel: String? {
        guard let maxShindo, !maxShindo.isEmpty else { return nil }
        return "震度\(maxShindo)"
    }
}

/// 地震预警（EEW）事件
struct EarlyWarning: Identifiable, Codable, Hashable {
    let id: String
    let eventID: String
    let reportNum: Int
    let magnitude: Double
    let latitude: Double
    let longitude: Double
    let depth: Double?
    let hypocenter: String
    let originTime: Date
    let reportTime: Date
    let maxIntensity: Double?
    let maxShindoLabel: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var warningLevel: WarningLevel {
        WarningLevel.from(magnitude: magnitude, maxIntensity: maxIntensity)
    }
}

enum WarningLevel: String, CaseIterable {
    case none
    case weak
    case moderate
    case strong
    case severe

    var title: String {
        switch self {
        case .none: return "情報なし"
        case .weak: return "弱い揺れ"
        case .moderate: return "中程度"
        case .strong: return "強い揺れ"
        case .severe: return "非常に強い"
        }
    }

    var colorName: String {
        switch self {
        case .none: return "gray"
        case .weak: return "yellow"
        case .moderate: return "orange"
        case .strong: return "red"
        case .severe: return "purple"
        }
    }

    static func from(magnitude: Double, maxIntensity: Double?) -> WarningLevel {
        let shindo = maxIntensity ?? magnitudeToShindoEstimate(magnitude)
        switch shindo {
        case ..<2: return .weak
        case 2..<4: return .moderate
        case 4..<5: return .strong
        default: return .severe
        }
    }

    /// マグニチュードから震度を粗く推定（緊急地震速報に震度がない場合）
    private static func magnitudeToShindoEstimate(_ magnitude: Double) -> Double {
        max(1, min(7, magnitude * 1.1))
    }
}

/// 用户感知的预警状态（含倒计时）
struct ActiveWarning: Identifiable {
    let warning: EarlyWarning
    let distanceKm: Double
    let estimatedArrivalSeconds: Int
    let detectedAt: Date

    var id: String { warning.id }

    var isExpired: Bool {
        estimatedArrivalSeconds <= 0
    }
}
