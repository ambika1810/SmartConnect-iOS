//
//  LocationView.swift
//  MyApp
//
//  Created by Ambika Patil on 14/10/26.
//



import SwiftUI

struct LocationView: View {

    @StateObject private var viewModel = LocationViewModel()

    var body: some View {
        VStack(spacing: 24) {

            // Location icon
            Image(systemName: "location.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.blue)

            // Screen title
            Text("GPS & Location")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Find your current location")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Location information
            VStack(alignment: .leading, spacing: 16) {

                Label {
                    Text(viewModel.statusMessage)
                        .font(.headline)
                } icon: {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.blue)
                }

                Divider()

                coordinateRow(
                    title: "Latitude",
                    value: viewModel.latitude.map {
                        String(format: "%.6f", $0)
                    } ?? "Not available"
                )

                coordinateRow(
                    title: "Longitude",
                    value: viewModel.longitude.map {
                        String(format: "%.6f", $0)
                    } ?? "Not available"
                )

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            // Request location button
            Button {
                viewModel.requestLocation()
            } label: {
                HStack {
                    if viewModel.isLocating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "location.fill")
                    }

                    Text(
                        viewModel.isLocating
                        ? "Finding Location..."
                        : "Get My Location"
                    )
                    .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLocating)

            Spacer()
        }
        .padding()
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            viewModel.stopLocationUpdates()
        }
    }

    private func coordinateRow(
        title: String,
        value: String
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
                .monospacedDigit()
                .textSelection(.enabled)
        }
    }
}

#Preview {
    NavigationStack {
        LocationView()
    }
}
