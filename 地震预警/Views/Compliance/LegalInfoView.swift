import SwiftUI

struct LegalInfoView: View {
    var body: some View {
        List {
            Section("重要なお知らせ") {
                Label {
                    Text("本アプリは気象庁の公式緊急地震速報発表システムではありません。法的な公式発表に代わるものではありません。")
                } icon: {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundStyle(.orange)
                }

                Label {
                    Text("通知・カウントダウンは公開データに基づく推定であり、誤差があります。唯一の避難判断の根拠にしないでください。")
                } icon: {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                }
            }

            Section("データ出典") {
                LabeledContent("地震情報", value: "Wolfx API（気象庁公開情報の転送）")
                LabeledContent("緊急地震速報", value: "Wolfx API（第三者・非公式）")
                Link("気象庁", destination: URL(string: "https://www.jma.go.jp/")!)
                Link("Wolfx Project", destination: URL(string: "https://wolfx.jp/")!)
            }

            Section("ポリシー") {
                NavigationLink("プライバシーポリシー") {
                    PrivacyPolicyView()
                }
                NavigationLink("利用規約") {
                    UserAgreementView()
                }
            }

            Section("権限") {
                Text("位置情報：震源からの距離・到達時間の推定に使用（拒否可）")
                Text("通知：ローカル通知に使用（拒否可）")
                Text("トラッキング：広告の最適化に使用（システム設定でオフ可）")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .navigationTitle("免責・出典")
    }
}
