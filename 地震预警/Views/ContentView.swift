import GoogleMobileAds
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @ObservedObject private var compliance = ComplianceManager.shared

    var body: some View {
        Group {
            if compliance.isFullyCompliant {
                mainInterface
            } else {
                ComplianceConsentView(compliance: compliance)
            }
        }
        .task(id: compliance.isFullyCompliant) {
            guard compliance.isFullyCompliant else { return }
            if AdConfig.adsEnabled {
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
            await viewModel.start()
            AdConfig.requestTrackingAuthorizationIfNeeded()
        }
    }

    private var mainInterface: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem {
                        Label("ホーム", systemImage: "house.fill")
                    }

                EarthquakeMapView(events: viewModel.events, activeWarning: viewModel.activeWarning)
                    .tabItem {
                        Label("マップ", systemImage: "map.fill")
                    }

                EventListView(events: viewModel.events)
                    .environmentObject(viewModel)
                    .tabItem {
                        Label("一覧", systemImage: "list.bullet")
                    }

                SettingsView()
                    .tabItem {
                        Label("設定", systemImage: "gearshape.fill")
                    }
            }

            if let activeWarning = viewModel.activeWarning {
                WarningAlertView(
                    activeWarning: activeWarning,
                    onDismiss: viewModel.dismissActiveWarning
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .allowsHitTesting(true)
            }
        }
        .animation(.spring(duration: 0.35), value: viewModel.activeWarning?.id)
    }
}

