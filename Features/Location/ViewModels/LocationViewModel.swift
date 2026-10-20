//
//  LocationViewModel.swift.swift
//  MyApp
//
//  Created by Ambika Patil on 14/10/26.
//


import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationViewModel: ObservableObject {

    @Published private(set) var latitude: Double?
    @Published private(set) var longitude: Double?
    @Published private(set) var statusMessage =
        "Location permission not requested"
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLocating = false

    private let locationService: LocationService
    private var cancellables = Set<AnyCancellable>()

    init(locationService: LocationService? = nil) {
        let service = locationService ?? LocationService()
        self.locationService = service

        service.$location
            .sink { [weak self] location in
                guard let self, let location else { return }

                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                self.statusMessage = "Location found"
                self.isLocating = false
                self.errorMessage = nil
            }
            .store(in: &cancellables)

        service.$authorizationStatus
            .sink { [weak self] status in
                self?.updateAuthorizationMessage(status)
            }
            .store(in: &cancellables)

        service.$errorMessage
            .sink { [weak self] message in
                self?.errorMessage = message

                if message != nil {
                    self?.isLocating = false
                }
            }
            .store(in: &cancellables)
    }

  
    func requestLocation() {
        isLocating = true
        errorMessage = nil
        statusMessage = "Requesting location permission..."

        locationService.requestPermission()

        if errorMessage != nil {
            isLocating = false
        }
    }

    func stopLocationUpdates() {
        locationService.stopUpdatingLocation()
        isLocating = false
    }

    private func updateAuthorizationMessage(
        _ status: CLAuthorizationStatus
    ) {
        switch status {
        case .notDetermined:
            statusMessage = "Location permission not requested"

        case .authorizedWhenInUse, .authorizedAlways:
            statusMessage = latitude == nil
                ? "Waiting for your location..."
                : "Location found"

        case .denied:
            statusMessage = "Location access denied"

        case .restricted:
            statusMessage = "Location access restricted"

        @unknown default:
            statusMessage = "Unknown permission status"
        }
    }
}
