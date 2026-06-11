import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: AppViewModel

    private let horizontalPadding: CGFloat = 16
    /// 为底部浮动 Tab 栏留出滚动空间
    private let tabBarScrollPadding: CGFloat = 72

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    statusCard

                    Text("最新の地震情報")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.top, 4)

                    if viewModel.isLoading && viewModel.events.isEmpty {
                        ProgressView("読み込み中…")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else if viewModel.events.isEmpty {
                        ContentUnavailableView("データがありません", systemImage: "waveform.path.ecg")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 24)
                    } else {
                        ForEach(viewModel.events.prefix(8)) { event in
                            EventRowView(event: event)
                        }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, tabBarScrollPadding)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("地震速報ヘルパー")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refreshEarthquakeList()
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                homeBottomInset
            }
        }
    }

    @ViewBuilder
    private var homeBottomInset: some View {
        VStack(spacing: 0) {
            BannerAdContainer(placement: .home)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(viewModel.webSocketService.isConnected ? Color.green : Color.orange)
                    .frame(width: 10, height: 10)
                Text(viewModel.webSocketService.isConnected ? "リアルタイム接続中" : "接続中…")
                    .font(.headline)
                Spacer(minLength: 0)
                if viewModel.notificationService.isAuthorized {
                    Label("通知オン", systemImage: "bell.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let location = viewModel.locationService.currentLocation {
                Text(String(format: "現在地：%.4f, %.4f", location.latitude, location.longitude))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("位置情報を取得中…設定アプリで位置情報を許可してください。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct EventRowView: View {
    let event: EarthquakeEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(event.magnitudeLabel)
                .font(.title2.bold())
                .foregroundStyle(magnitudeColor)
                .frame(width: 52, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.locationName)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(event.originTime.formatted(date: .abbreviated, time: .standard))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(eventDetailSubtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var eventDetailSubtitle: String {
        var parts: [String] = []
        if let shindo = event.shindoLabel { parts.append(shindo) }
        parts.append("深さ \(event.depthLabel)")
        parts.append("気象庁")
        return parts.joined(separator: " · ")
    }

    private var magnitudeColor: Color {
        switch event.magnitude {
        case ..<3: return .green
        case 3..<5: return .orange
        case 5..<7: return .red
        default: return .purple
        }
    }
}
