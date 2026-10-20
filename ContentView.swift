
import SwiftUI

enum SmartFindFeature: String, CaseIterable, Identifiable, Hashable {
    case location
    case bluetooth
    case uwb
    case nfc

    var id: String { rawValue }

    var title: String {
        switch self {
        case .location: "GPS & Location"
        case .bluetooth: "Bluetooth LE"
        case .uwb: "Ultra-Wideband"
        case .nfc: "NFC Scanner"
        }
    }

    var subtitle: String {
        switch self {
        case .location: "Find your item's last location"
        case .bluetooth: "Discover nearby trackers"
        case .uwb: "Precision finding"
        case .nfc: "Identify tagged belongings"
        }
    }

    var symbol: String {
        switch self {
        case .location: "location.fill"
        case .bluetooth: "antenna.radiowaves.left.and.right"
        case .uwb: "dot.radiowaves.left.and.right"
        case .nfc: "wave.3.right"
        }
    }

    var color: Color {
        switch self {
        case .location: .blue
        case .bluetooth: .indigo
        case .uwb: .purple
        case .nfc: .orange
        }
    }
}

struct ContentView: View {
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    NavigationLink {
                        ScansView()
                    } label: {
                        Label("View Cloud Scans", systemImage: "cloud")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(SmartFindFeature.allCases) { feature in
                            NavigationLink(value: feature) {
                                featureCard(feature)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Label(
                        "Hardware availability depends on your device.",
                        systemImage: "info.circle"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
                .padding(20)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("SmartFind")
            .navigationDestination(for: SmartFindFeature.self) { feature in
                switch feature {
                case .location:
                    SavedLocationsView()

                case .bluetooth, .uwb, .nfc:
                    FeatureDetailView(feature: feature)
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find what matters.")
                .font(.largeTitle.bold())

            Text("Locate, discover and identify your belongings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func featureCard(
        _ feature: SmartFindFeature
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: feature.symbol)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(feature.color)

            Text(feature.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(feature.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(feature.color)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 175)
        .background(feature.color.opacity(0.09))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(feature.color.opacity(0.12))
        }
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct FeatureDetailView: View {
    let feature: SmartFindFeature

    var body: some View {
        

        Group {
            switch feature {
            case .bluetooth:
                BLEDiscoveryView()

            case .uwb:
                UWBView()

            case .nfc:
                NFCScannerView()

            case .location:
                VStack(spacing: 20) {
                    Image(systemName: feature.symbol)
                        .font(.system(size: 56))
                        .foregroundStyle(feature.color)

                    Text(feature.title)
                        .font(.title.bold())

                    Text(feature.subtitle)
                        .foregroundStyle(.secondary)

                    Text("We'll implement this feature in its own module.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
        .navigationTitle(feature.title)

    }
}
