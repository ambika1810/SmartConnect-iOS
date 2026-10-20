//
//  SavedLocations.swift
//  MyApp
//
//  Created by Ambika Patil on 14/10/26.
//




import Foundation
import CoreLocation

struct SavedLocation: Identifiable, Codable {
    var id: UUID = UUID()
    let itemName: String
    let latitude: Double
    let longitude: Double
    let savedAt: Date
    var notes: String = ""

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case itemName
        case latitude
        case longitude
        case savedAt
        case notes
    }

    init(
        id: UUID = UUID(),
        itemName: String,
        latitude: Double,
        longitude: Double,
        savedAt: Date,
        notes: String = ""
    ) {
        self.id = id
        self.itemName = itemName
        self.latitude = latitude
        self.longitude = longitude
        self.savedAt = savedAt
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(UUID.self, forKey: .id)
        itemName = try container.decode(
            String.self,
            forKey: .itemName
        )
        latitude = try container.decode(
            Double.self,
            forKey: .latitude
        )
        longitude = try container.decode(
            Double.self,
            forKey: .longitude
        )
        savedAt = try container.decode(
            Date.self,
            forKey: .savedAt
        )
        notes = try container.decodeIfPresent(
            String.self,
            forKey: .notes
        ) ?? ""
    }
}
