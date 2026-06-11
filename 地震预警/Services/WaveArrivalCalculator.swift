import Foundation
import CoreLocation

enum WaveArrivalCalculator {
    /// S 波地表近似速度（km/s）
    private static let sWaveSpeedKmPerSec = 3.5

    static func distanceKm(
        from user: CLLocationCoordinate2D,
        to epicenter: CLLocationCoordinate2D
    ) -> Double {
        let userLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
        let epicenterLocation = CLLocation(latitude: epicenter.latitude, longitude: epicenter.longitude)
        return userLocation.distance(from: epicenterLocation) / 1000
    }

    /// 估算 S 波到达剩余秒数（简化模型，不含深度与地壳结构）
    static func estimatedArrivalSeconds(
        originTime: Date,
        user: CLLocationCoordinate2D,
        epicenter: CLLocationCoordinate2D,
        now: Date = .now
    ) -> Int {
        let distance = distanceKm(from: user, to: epicenter)
        let travelSeconds = distance / sWaveSpeedKmPerSec
        let elapsed = now.timeIntervalSince(originTime)
        return max(0, Int(ceil(travelSeconds - elapsed)))
    }

    static func shouldAlert(
        warning: EarlyWarning,
        userLocation: CLLocationCoordinate2D?,
        minMagnitude: Double,
        maxDistanceKm: Double
    ) -> Bool {
        guard warning.magnitude >= minMagnitude else { return false }
        guard let userLocation else { return true }

        let distance = distanceKm(from: userLocation, to: warning.coordinate)
        return distance <= maxDistanceKm
    }
}
