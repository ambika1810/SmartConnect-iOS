//
//  ScanView.swift
//  MyApp
//
//  Created by Ambika Patil on 16/10/26.
//


import SwiftUI

struct ScansView: View {
    @State private var scans: [Scan] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading scans...")
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else if scans.isEmpty {
                ContentUnavailableView(
                    "No Scans Yet",
                    systemImage: "dot.radiowaves.left.and.right",
                    description: Text("Your API is connected, but no scans are saved.")
                )
            } else {
                ForEach(scans) { scan in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(scan.deviceName ?? scan.scanType)
                            .font(.headline)

                        Text("Type: \(scan.scanType)")

                        if let rssi = scan.rssi {
                            Text("Signal: \(rssi) dBm")
                        }

                        if let tagData = scan.tagData {
                            Text("Tag: \(tagData)")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Cloud Scans")
        .toolbar {
            Button("Refresh") {
                Task {
                    await loadScans()
                }
            }
        }
        .task {
            await loadScans()
        }
    }

    @MainActor
    private func loadScans() async {
        isLoading = true
        errorMessage = nil

        do {
            scans = try await APIService.shared.fetchScans()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
