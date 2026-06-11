import GoogleMobileAds
import SwiftUI
import UIKit

struct BannerAdContainer: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let placement: AdPlacement

    private let bannerHeight: CGFloat = 50

    var body: some View {
        if viewModel.activeWarning == nil, AdConfig.adsEnabled {
            BannerAdView(adUnitID: AdConfig.bannerUnitID(for: placement))
                .frame(maxWidth: .infinity)
                .frame(height: bannerHeight)
                .background(Color(.secondarySystemBackground))
                .clipped()
                .accessibilityLabel("広告")
        }
    }
}

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    var onLoaded: (() -> Void)?
    var onFailed: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(onLoaded: onLoaded, onFailed: onFailed)
    }

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        load(banner)
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        context.coordinator.onLoaded = onLoaded
        context.coordinator.onFailed = onFailed
        if uiView.rootViewController == nil {
            load(uiView)
        }
    }

    private func load(_ banner: GADBannerView) {
        DispatchQueue.main.async {
            banner.rootViewController = Self.topViewController()
            guard banner.rootViewController != nil else { return }
            banner.load(GADRequest())
        }
    }

    private static func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: \.isKeyWindow)?.rootViewController
        else { return nil }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }

    final class Coordinator: NSObject, GADBannerViewDelegate {
        var onLoaded: (() -> Void)?
        var onFailed: (() -> Void)?

        init(onLoaded: (() -> Void)?, onFailed: (() -> Void)?) {
            self.onLoaded = onLoaded
            self.onFailed = onFailed
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            DispatchQueue.main.async { self.onLoaded?() }
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            DispatchQueue.main.async { self.onFailed?() }
        }
    }
}
