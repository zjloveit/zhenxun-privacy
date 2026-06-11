import MapKit
import SwiftUI

struct EarthquakeMapView: View {
    let events: [EarthquakeEvent]
    let activeWarning: ActiveWarning?

    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        NavigationStack {
            Map(position: $position) {
                UserAnnotation()

                ForEach(events.prefix(50)) { event in
                    Annotation(event.locationName, coordinate: event.coordinate) {
                        Circle()
                            .fill(color(for: event.magnitude))
                            .frame(width: markerSize(for: event.magnitude), height: markerSize(for: event.magnitude))
                            .overlay {
                                Text(event.magnitudeLabel)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            }
                    }
                }

                if let activeWarning {
                    Annotation("緊急地震速報の震源", coordinate: activeWarning.warning.coordinate) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, .red)
                            .padding(8)
                            .background(Circle().fill(.red))
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .navigationTitle("地震マップ")
            .onAppear {
                updateCamera()
            }
            .onChange(of: activeWarning?.id) { _, _ in
                updateCamera()
            }
        }
    }

    private func updateCamera() {
        if let activeWarning {
            position = .region(MKCoordinateRegion(
                center: activeWarning.warning.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 4, longitudeDelta: 4)
            ))
        } else if let first = events.first {
            position = .region(MKCoordinateRegion(
                center: first.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
            ))
        } else {
            position = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.2, longitude: 138.3),
                span: MKCoordinateSpan(latitudeDelta: 12, longitudeDelta: 12)
            ))
        }
    }

    private func color(for magnitude: Double) -> Color {
        switch magnitude {
        case ..<3: return .green
        case 3..<5: return .orange
        case 5..<7: return .red
        default: return .purple
        }
    }

    private func markerSize(for magnitude: Double) -> CGFloat {
        CGFloat(min(44, max(24, magnitude * 6)))
    }
}

