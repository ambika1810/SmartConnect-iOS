//
//  SavedLocationViewModel.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
final class SavedLocationViewModel: ObservableObject {

    @Published private(set) var savedLocations: [SavedLocation] = [] {
        didSet {
            saveToStorage()
        }
    }

    private let storageKey = "smartfind.savedLocations"

    init() {
        loadFromStorage()
    }

   
    func saveLocation(
        itemName: String,
        latitude: Double,
        longitude: Double,
        notes: String = ""
    ) {
        let trimmedName = itemName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else { return }

        let savedLocation = SavedLocation(
            itemName: trimmedName,
            latitude: latitude,
            longitude: longitude,
            savedAt: Date(),
            notes: notes.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        )

        savedLocations.insert(savedLocation, at: 0)
    }


    func deleteLocation(at offsets: IndexSet) {
        savedLocations.remove(atOffsets: offsets)
    }

    private func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(savedLocations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save locations: \(error.localizedDescription)")
        }
    }

    private func loadFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            savedLocations = try JSONDecoder().decode(
                [SavedLocation].self,
                from: data
            )
        } catch {
            print("Failed to load locations: \(error.localizedDescription)")
        }
    }
    

    func updateItem(
        id: UUID,
        newName: String,
        newNotes: String
    ) {
        let trimmedName = newName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else { return }

        guard let index = savedLocations.firstIndex(
            where: { $0.id == id }
        ) else {
            return
        }

        let existingLocation = savedLocations[index]

        savedLocations[index] = SavedLocation(
            id: existingLocation.id,
            itemName: trimmedName,
            latitude: existingLocation.latitude,
            longitude: existingLocation.longitude,
            savedAt: existingLocation.savedAt,
            notes: newNotes.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        )
    }

}
