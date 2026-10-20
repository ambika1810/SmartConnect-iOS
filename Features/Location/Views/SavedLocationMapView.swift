//
//  SavedLocationMapView.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import SwiftUI
import MapKit

struct SavedLocationMapView: View {

    let location: SavedLocation

    @State private var cameraPosition: MapCameraPosition

    init(location: SavedLocation) {
        self.location = location

        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )

        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.01,
                        longitudeDelta: 0.01
                    )
                )
            )
        )
    }

    var body: some View {
        Map(
            position: $cameraPosition
        ) {
            Marker(
                location.itemName,
                coordinate: location.coordinate
            )
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .navigationTitle(location.itemName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SavedLocationMapView(
            location: SavedLocation(
                itemName: "House Keys",
                latitude: 19.0760,
                longitude: 72.8777,
                savedAt: .now
            )
        )
    }
}
