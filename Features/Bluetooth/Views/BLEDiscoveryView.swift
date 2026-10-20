//
//  BLEDiscoveryView.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import SwiftUI

struct BLEDiscoveryView: View {

    @StateObject private var bleManager = BLEManager()

    var body: some View {
        VStack(spacing: 20) {

            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 55))
                .foregroundStyle(.blue)

            Text("Bluetooth Discovery")
                .font(.title2)
                .fontWeight(.bold)

            Text(bleManager.status)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(bleManager.cloudStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button {
                    bleManager.startScanning()
                } label: {
                    Label("Start Scan", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(bleManager.isScanning)

                Button {
                    bleManager.stopScanning()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(!bleManager.isScanning)
            }

            List {
                Section("Discovered Devices") {
                    if bleManager.discoveredDevices.isEmpty {
                        Text("No devices discovered yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            Array(bleManager.discoveredDevices.enumerated()),
                            id: \.offset
                        ) { _, device in
                            Label(
                                device,
                                systemImage: "dot.radiowaves.left.and.right"
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .padding()
        .navigationTitle("BLE Scanner")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            bleManager.stopScanning()
        }
    }
}

#Preview {
    NavigationStack {
        BLEDiscoveryView()
    }
}
