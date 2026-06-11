import Foundation

/// プライバシー同意・利用規約バージョン管理
@MainActor
final class ComplianceManager: ObservableObject {
    static let shared = ComplianceManager()

    private let consentKey = "compliance.privacyConsentAccepted"
    private let consentVersionKey = "compliance.privacyConsentVersion"
    private let agreementKey = "compliance.userAgreementAccepted"

    /// 隐私政策更新时递增，会要求用户重新确认
    static let currentPolicyVersion = "2026-06-01"

    @Published private(set) var hasAcceptedPrivacyPolicy = false
    @Published private(set) var hasAcceptedUserAgreement = false

    var isFullyCompliant: Bool {
        hasAcceptedPrivacyPolicy && hasAcceptedUserAgreement
    }

    private init() {
        load()
    }

    func load() {
        let version = UserDefaults.standard.string(forKey: consentVersionKey)
        hasAcceptedPrivacyPolicy =
            UserDefaults.standard.bool(forKey: consentKey)
            && version == Self.currentPolicyVersion
        hasAcceptedUserAgreement = UserDefaults.standard.bool(forKey: agreementKey)
    }

    func acceptPrivacyPolicy() {
        UserDefaults.standard.set(true, forKey: consentKey)
        UserDefaults.standard.set(Self.currentPolicyVersion, forKey: consentVersionKey)
        hasAcceptedPrivacyPolicy = true
    }

    func acceptUserAgreement() {
        UserDefaults.standard.set(true, forKey: agreementKey)
        hasAcceptedUserAgreement = true
    }

    func acceptAll() {
        acceptPrivacyPolicy()
        acceptUserAgreement()
    }

}
