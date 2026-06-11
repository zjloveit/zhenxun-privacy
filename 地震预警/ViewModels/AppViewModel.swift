import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    @Published var events: [EarthquakeEvent] = []
    @Published var activeWarning: ActiveWarning?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var minMagnitude: Double = 3.0
    @Published var maxAlertDistanceKm: Double = 800
    @Published var useWebSocket = true

    let locationService = LocationService()
    let notificationService = NotificationService()
    let alertSoundService = AlertSoundService()
    let webSocketService = WebSocketService()

    private let apiClient = WolfxAPIClient()
    private var refreshTask: Task<Void, Never>?
    private var countdownTask: Task<Void, Never>?
    private var handledWarningKeys: Set<String> = []

    init() {
        webSocketService.onEarlyWarning = { [weak self] warning in
            Task { @MainActor in
                self?.handleEarlyWarning(warning)
            }
        }
    }

    func start() async {
        await notificationService.requestAuthorization()
        locationService.requestPermission()
        locationService.startUpdating()

        if useWebSocket {
            webSocketService.connect()
        }

        refreshTask?.cancel()
        refreshTask = Task {
            while !Task.isCancelled {
                await refreshEarthquakeList()
                if !useWebSocket {
                    await pollEarlyWarning()
                }
                try? await Task.sleep(for: .seconds(15))
            }
        }
    }

    func stop() {
        refreshTask?.cancel()
        countdownTask?.cancel()
        alertSoundService.stop()
        webSocketService.disconnect()
        locationService.stopUpdating()
    }

    func refreshEarthquakeList() async {
        isLoading = events.isEmpty
        errorMessage = nil

        do {
            events = try await apiClient.fetchEarthquakeList()
        } catch {
            if events.isEmpty {
                errorMessage = error.localizedDescription
            }
        }

        isLoading = false
    }

    func pollEarlyWarning() async {
        do {
            if let warning = try await apiClient.fetchLatestEarlyWarning() {
                handleEarlyWarning(warning)
            }
        } catch {
            // 无预警时接口可能返回空 payload，忽略即可
        }
    }

    func dismissActiveWarning() {
        activeWarning = nil
        countdownTask?.cancel()
        alertSoundService.stop()
    }

    private func handleEarlyWarning(_ warning: EarlyWarning) {
        let dedupeKey = "\(warning.eventID)-\(warning.reportNum)"
        guard !handledWarningKeys.contains(dedupeKey) else { return }

        guard WaveArrivalCalculator.shouldAlert(
            warning: warning,
            userLocation: locationService.currentLocation,
            minMagnitude: minMagnitude,
            maxDistanceKm: maxAlertDistanceKm
        ) else { return }

        handledWarningKeys.insert(dedupeKey)

        let user = locationService.currentLocation ?? warning.coordinate
        let distance = WaveArrivalCalculator.distanceKm(from: user, to: warning.coordinate)
        let arrival = WaveArrivalCalculator.estimatedArrivalSeconds(
            originTime: warning.originTime,
            user: user,
            epicenter: warning.coordinate
        )

        let active = ActiveWarning(
            warning: warning,
            distanceKm: distance,
            estimatedArrivalSeconds: arrival,
            detectedAt: .now
        )

        presentWarning(active)
    }

    private func presentWarning(_ active: ActiveWarning) {
        activeWarning = active
        startCountdown(for: active)
        alertSoundService.playWarningAlert(repeating: true)

        Task {
            await notificationService.notifyIfNeeded(for: active)
        }
    }

    private func startCountdown(for active: ActiveWarning) {
        countdownTask?.cancel()
        countdownTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))

                guard let current = activeWarning else { return }

                let user = locationService.currentLocation ?? current.warning.coordinate
                let remaining = WaveArrivalCalculator.estimatedArrivalSeconds(
                    originTime: current.warning.originTime,
                    user: user,
                    epicenter: current.warning.coordinate
                )

                if remaining <= 0 {
                    activeWarning = nil
                    return
                }

                activeWarning = ActiveWarning(
                    warning: current.warning,
                    distanceKm: WaveArrivalCalculator.distanceKm(from: user, to: current.warning.coordinate),
                    estimatedArrivalSeconds: remaining,
                    detectedAt: current.detectedAt
                )
            }
        }
    }
}

private extension EarlyWarning {
    var magnitudeLabel: String {
        String(format: "%.1f", magnitude)
    }
}
