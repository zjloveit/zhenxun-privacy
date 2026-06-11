import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("通知設定") {
                    VStack(alignment: .leading) {
                        Text("最小マグニチュード：M\(String(format: "%.1f", viewModel.minMagnitude))")
                        Slider(value: $viewModel.minMagnitude, in: 2...7, step: 0.5)
                    }

                    VStack(alignment: .leading) {
                        Text("最大通知距離：\(Int(viewModel.maxAlertDistanceKm)) km")
                        Slider(value: $viewModel.maxAlertDistanceKm, in: 50...2000, step: 50)
                    }

                    Toggle("リアルタイム受信（WebSocket）", isOn: $viewModel.useWebSocket)
                        .onChange(of: viewModel.useWebSocket) { _, enabled in
                            if enabled {
                                viewModel.webSocketService.connect()
                            } else {
                                viewModel.webSocketService.disconnect()
                            }
                        }
                }

                Section("権限") {
                    LabeledContent("位置情報") {
                        Text(locationStatusText)
                    }
                    LabeledContent("通知") {
                        Text(viewModel.notificationService.isAuthorized ? "許可済み" : "未許可")
                    }

                    Button("通知の許可を再リクエスト") {
                        Task { await viewModel.notificationService.requestAuthorization() }
                    }
                }

                Section {
                    NavigationLink("免責事項・データ出典") {
                        LegalInfoView()
                    }
                } header: {
                    Text("コンプライアンス")
                } footer: {
                    Text("本アプリは第三者の地震情報サービスであり、気象庁の公式緊急地震速報アプリではありません。")
                        .font(.footnote)
                }

                Section {
                    BannerAdContainer(placement: .settings)
                } header: {
                    Text("広告")
                } footer: {
                    Text("緊急地震速報の全画面表示中は広告を表示しません。")
                        .font(.footnote)
                }
            }
            .navigationTitle("設定")
        }
    }

    private var locationStatusText: String {
        switch viewModel.locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return "許可済み"
        case .denied, .restricted: return "拒否"
        case .notDetermined: return "未設定"
        @unknown default: return "不明"
        }
    }
}
