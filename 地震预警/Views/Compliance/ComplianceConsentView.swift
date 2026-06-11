import SwiftUI

/// 初回起動時のプライバシー・利用規約同意
struct ComplianceConsentView: View {
    @ObservedObject var compliance: ComplianceManager
    @State private var agreedPrivacy = false
    @State private var agreedTerms = false
    @State private var showPrivacy = false
    @State private var showTerms = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "waveform.path.ecg.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)

                    Text("地震速報ヘルパーへようこそ")
                        .font(.title.bold())
                        .frame(maxWidth: .infinity)

                    Text("本アプリは第三者の地震情報サービスであり、気象庁の公式緊急地震速報アプリではありません。データに遅延が生じる場合があります。地震時はテレビ・防災無線など公式情報を優先してください。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $agreedPrivacy) {
                            HStack(spacing: 4) {
                                Text("同意する：")
                                Button("プライバシーポリシー") { showPrivacy = true }
                                    .buttonStyle(.plain)
                            }
                        }

                        Toggle(isOn: $agreedTerms) {
                            HStack(spacing: 4) {
                                Text("同意する：")
                                Button("利用規約") { showTerms = true }
                                    .buttonStyle(.plain)
                            }
                        }
                    }

                    Button("同意して続行") {
                        compliance.acceptAll()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!agreedPrivacy || !agreedTerms)
                    .frame(maxWidth: .infinity)

                    Text("「設定 → 免責事項・データ出典」からいつでも確認できます。")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(24)
            }
            .navigationTitle("サービス説明")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPrivacy) {
                NavigationStack {
                    PrivacyPolicyView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("閉じる") { showPrivacy = false }
                            }
                        }
                }
            }
            .sheet(isPresented: $showTerms) {
                NavigationStack {
                    UserAgreementView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("閉じる") { showTerms = false }
                            }
                        }
                }
            }
        }
    }
}
