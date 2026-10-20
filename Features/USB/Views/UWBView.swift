//
//  USBView.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import SwiftUI
import NearbyInteraction

struct UWBView: View {
    @StateObject private var viewModel = UWBManager()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Ultra-Wideband")
                .font(.title.bold())

            Text("Nearby Interaction")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                Text("Device Status")
                    .font(.headline)

                Text(viewModel.status)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if let distance = viewModel.distance {
                    Text(String(format: "Distance: %.2f m", distance))
                        .font(.title2.bold())
                }

                if let direction = viewModel.direction {
                    Text(
                        String(
                            format: "Direction: %.2f, %.2f, %.2f",
                            direction.x,
                            direction.y,
                            direction.z
                        )
                    )
                    .font(.callout)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Color(uiColor: .secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button("Check UWB Support") {
                viewModel.checkAvailability()
            }
            .buttonStyle(.bordered)

            Button("Start Peer Discovery") {
                viewModel.startPeerDiscovery()
            }
            .buttonStyle(.borderedProminent)

            Button("Stop UWB") {
                viewModel.stopRanging()
            }
            .buttonStyle(.bordered)

            Text(
                "Real distance measurements require compatible physical devices. " +
                "Allow local-network access when prompted."
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .navigationTitle("UWB Finder")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.checkAvailability()
        }
    }
}

#Preview {
    NavigationStack {
        UWBView()
    }
}
