import AVFoundation
import AudioToolbox
import UIKit

/// 应用内预警警报（前台弹窗时播放，静音模式下也可响）
@MainActor
final class AlertSoundService {
    private var player: AVAudioPlayer?
    private var repeatTask: Task<Void, Never>?

    func playWarningAlert(repeating: Bool = true) {
        stop()
        configureAudioSession()
        playOnce()
        triggerHaptic()

        guard repeating else { return }

        repeatTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2.5))
                guard !Task.isCancelled else { return }
                playOnce()
                triggerHaptic()
            }
        }
    }

    func stop() {
        repeatTask?.cancel()
        repeatTask = nil
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true)
    }

    private func playOnce() {
        if let url = Bundle.main.url(forResource: "EEWAlarm", withExtension: "wav") {
            playBundledAlarm(url: url)
        } else {
            AudioServicesPlayAlertSound(SystemSoundID(1304))
        }
    }

    private func playBundledAlarm(url: URL) {
        do {
            let alarmPlayer = try AVAudioPlayer(contentsOf: url)
            alarmPlayer.numberOfLoops = 0
            alarmPlayer.volume = 1.0
            alarmPlayer.prepareToPlay()
            alarmPlayer.play()
            player = alarmPlayer
        } catch {
            AudioServicesPlayAlertSound(SystemSoundID(1304))
        }
    }

    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
}
