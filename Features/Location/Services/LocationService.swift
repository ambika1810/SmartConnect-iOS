//
//  LocationService.swift.swift
//  MyApp
//
//  Created by Ambika Patil on 14/10/26.
//


import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {

    @Published private(set) var location: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var errorMessage: String?

    private let locationManager = CLLocationManager()

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        super.init()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()

        case .denied, .restricted:
            errorMessage = "Location access is disabled. Enable it in Settings."

        @unknown default:
            errorMessage = "Unable to determine location permission."
        }
    }

  
    func startUpdatingLocation() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            errorMessage = nil
            locationManager.startUpdatingLocation()

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .denied, .restricted:
            errorMessage = "Location permission is required."

        @unknown default:
            errorMessage = "Unable to determine location permission."
        }
    }


    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            errorMessage = nil
            startUpdatingLocation()

        case .denied, .restricted:
            stopUpdatingLocation()
            errorMessage = "Location access is denied or restricted."

        case .notDetermined:
            break

        @unknown default:
            errorMessage = "Unknown location authorization status."
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latestLocation = locations.last else { return }
        location = latestLocation
        errorMessage = nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        errorMessage = error.localizedDescription
    }
}

