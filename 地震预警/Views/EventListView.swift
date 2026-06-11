import SwiftUI

struct EventListView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    let events: [EarthquakeEvent]

    private let horizontalPadding: CGFloat = 16
    private let tabBarScrollPadding: CGFloat = 72

    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    ContentUnavailableView("地震情報がありません", systemImage: "list.bullet.rectangle")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(events) { event in
                                EventRowView(event: event)
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, 8)
                        .padding(.bottom, tabBarScrollPadding)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("地震一覧")
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BannerAdContainer(placement: .eventList)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
            }
        }
    }
}
