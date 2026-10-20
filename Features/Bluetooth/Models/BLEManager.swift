//
//  BLEManager.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import Foundation
import CoreBluetooth
import Combine

final class BLEManager: NSObject, ObservableObject {

    @Published var isScanning = false
    @Published var status = "Bluetooth is not initialized"
    @Published var discoveredDevices: [String] = []
    @Published var cloudStatus = "Cloud uploads ready"

    private var uploadedPeripheralIDs = Set<UUID>()
    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: .main
        )
    }

 
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            switch centralManager.state {
            case .poweredOff:
                status = "Bluetooth is turned off"
            case .unauthorized:
                status = "Bluetooth permission denied"
            case .unsupported:
                status = "Bluetooth LE is not supported"
            case .resetting:
                status = "Bluetooth is resetting"
            case .unknown:
                status = "Waiting for Bluetooth initialization"
            default:
                status = "Bluetooth is not ready"
            }
            return
        }

        discoveredDevices.removeAll()
        uploadedPeripheralIDs.removeAll()
        cloudStatus = "Scanning and cloud uploads ready"

        centralManager.scanForPeripherals(
            withServices: nil,
            options: nil
        )

        isScanning = true
        status = "Scanning for nearby BLE devices..."
    }


    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        status = "Scanning stopped"
    }
}

extension BLEManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(
        _ central: CBCentralManager
    ) {
        switch central.state {
        case .poweredOn:
            status = "Bluetooth is ready"
        case .poweredOff:
            status = "Bluetooth is turned off"
        case .unauthorized:
            status = "Bluetooth permission denied"
        case .unsupported:
            status = "Bluetooth LE is not supported"
        case .resetting:
            status = "Bluetooth is resetting"
        case .unknown:
            status = "Bluetooth state is unknown"
        @unknown default:
            status = "Unknown Bluetooth state"
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name
            ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? "Unnamed device"

        let peripheralID = peripheral.identifier

        // Upload each device only once per scan session.
        guard !uploadedPeripheralIDs.contains(peripheralID) else {
            return
        }

        uploadedPeripheralIDs.insert(peripheralID)

        let deviceDescription = "\(name) • RSSI: \(RSSI) dBm"
        discoveredDevices.append(deviceDescription)

        // Send the real Bluetooth discovery to the cloud API.
        Task { @MainActor in
            do {
                try await APIService.shared.uploadBLEScan(
                    deviceName: name,
                    rssi: RSSI.intValue,
                    tagData: peripheralID.uuidString
                )

                cloudStatus = "☁️ Saved \(name) to cloud"
            } catch {
                cloudStatus = "Upload failed: \(error.localizedDescription)"
            }
        }
    }
}
