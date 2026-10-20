//
//  NFCScannerView.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import SwiftUI

struct NFCScannerView: View {
    @StateObject private var nfcManager = NFCManager()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "wave.3.right")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("NFC Scanner")
                .font(.title.bold())

            Text("Read supported NFC tags")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                Text("Scan Status")
                    .font(.headline)

                Text(nfcManager.status)
                    .foregroundStyle(.secondary)

                Divider()

                Text("Tag Information")
                    .font(.headline)

                if nfcManager.tagInfo.isEmpty {
                    Text("No NFC tag data yet")
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        Text(nfcManager.tagInfo)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 220)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                Color(uiColor: .secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                nfcManager.startScanning()
            } label: {
                Label("Start NFC Scan", systemImage: "wave.3.right")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button("Stop Scanning") {
                nfcManager.stopScanning()
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
        .navigationTitle("NFC Scanner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NFCScannerView()
    }
}
