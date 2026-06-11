import SwiftUI

struct WarningAlertView: View {
    let activeWarning: ActiveWarning
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .font(.title)
                    Text("緊急地震速報")
                        .font(.title.bold())
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }

                Text(activeWarning.warning.hypocenter)
                    .font(.title2.bold())

                HStack(spacing: 24) {
                    metric(title: "マグニチュード", value: String(format: "M%.1f", activeWarning.warning.magnitude))
                    if let shindo = activeWarning.warning.maxShindoLabel {
                        metric(title: "予測震度", value: "震度\(shindo)")
                    }
                    metric(title: "距離", value: "\(Int(activeWarning.distanceKm)) km")
                    metric(title: "到達まで", value: "\(activeWarning.estimatedArrivalSeconds)秒")
                }

                Text("第三者データによる推定です。気象庁の公式発表ではありません。身の安全を確保し、テレビ・防災無線などの公式情報を確認してください。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("S波到達時間は参考値です。机の下に隠れるなど、直ちに避難行動を取ってください。")
                    .font(.caption2)
                    .foregroundStyle(.secondary.opacity(0.9))
            }
            .foregroundStyle(.white)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alertGradient)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()

            Spacer()
        }
        .background(Color.black.opacity(0.35).ignoresSafeArea())
    }

    private var alertGradient: LinearGradient {
        switch activeWarning.warning.warningLevel {
        case .weak, .moderate:
            return LinearGradient(colors: [.orange, .red.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .strong, .severe:
            return LinearGradient(colors: [.red, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .none:
            return LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .opacity(0.85)
            Text(value)
                .font(.title3.bold())
        }
    }
}
