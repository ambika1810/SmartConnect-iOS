//
//  SavedLocationsView.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import SwiftUI
import Combine
struct SavedLocationsView: View {

    @StateObject private var viewModel = SavedLocationViewModel()
    @StateObject private var locationViewModel = LocationViewModel()

    @State private var itemName = ""
    @State private var searchText = ""
    @State private var itemNotes = ""
    @State private var editingLocation: SavedLocation?
    @State private var editedName = ""
    @State private var editedNotes = ""
    var body: some View {
        VStack(spacing: 16) {

            TextField("Enter item name (e.g. House Keys)", text: $itemName)
                .textFieldStyle(.roundedBorder)

            TextField(
                "Notes (e.g. Inside the blue backpack)",
                text: $itemNotes,
                axis: .vertical
            )
            .textFieldStyle(.roundedBorder)
            .lineLimit(2...4)

            
            TextField("Search saved items...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .overlay(alignment: .trailing) {
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 10)
                    }
                }

            
            Button {
                locationViewModel.requestLocation()
            } label: {
                Label("Get Current Location", systemImage: "location.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                guard let latitude = locationViewModel.latitude,
                      let longitude = locationViewModel.longitude else {
                    return
                }

                viewModel.saveLocation(
                    itemName: itemName,
                    latitude: latitude,
                    longitude: longitude,
                    notes: itemNotes
                )

                itemName = ""
                itemNotes = ""
            } label: {
                Label("Save Item Location", systemImage: "bookmark.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(
                itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || locationViewModel.latitude == nil
                || locationViewModel.longitude == nil
            )

            if viewModel.savedLocations.isEmpty {
                ContentUnavailableView(
                    "No Saved Locations",
                    systemImage: "mappin.and.ellipse",
                    description: Text("Your saved items will appear here.")
                )
                .padding(.top, 24)
            } else {
                List {
                        ForEach(filteredLocations) { location in
                            
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(location.itemName)
                                    .font(.headline)

                                Text("Latitude: \(location.latitude)")
                                    .font(.caption)

                                Text("Longitude: \(location.longitude)")
                                    .font(.caption)

                                Text(
                                    location.savedAt.formatted(
                                        date: .abbreviated,
                                        time: .shortened
                                    )
                                )
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                
                                if !location.notes.isEmpty {
                                    Label {
                                        Text(location.notes)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    } icon: {
                                        Image(systemName: "note.text")
                                            .foregroundStyle(.blue)
                                    }
                                }

                            }

                            Spacer()

                            VStack(spacing: 16) {
                                Button {
                                    editedName = location.itemName
                                    editedNotes = location.notes
                                    editingLocation = location
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                }
                                .accessibilityLabel("Edit \(location.itemName)")

                                NavigationLink {
                                    SavedLocationMapView(location: location)
                                } label: {
                                    Image(systemName: "map")
                                        .font(.title3)
                                }
                                .accessibilityLabel("View \(location.itemName) on map")
                            }
                        }
                        .padding(.vertical, 4)


                    }
                        .onDelete { offsets in
                                    let idsToDelete = offsets.map {
                                        filteredLocations[$0].id
                                    }

                                    let originalOffsets = IndexSet(
                                        viewModel.savedLocations.enumerated().compactMap {
                                            idsToDelete.contains($0.element.id) ? $0.offset : nil
                                        }
                                    )

                                    viewModel.deleteLocation(at: originalOffsets)
                                }
                            }
                            .listStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .navigationTitle("Saved Locations")
        .sheet(item: $editingLocation) { location in
            NavigationStack {
                Form {
                 
                    Section("Item Details") {
                        TextField("Item name", text: $editedName)

                        TextField(
                            "Notes",
                            text: $editedNotes,
                            axis: .vertical
                        )
                        
                    }


                    Section {
                        LabeledContent(
                            "Latitude",
                            value: String(format: "%.6f", location.latitude)
                        )

                        LabeledContent(
                            "Longitude",
                            value: String(format: "%.6f", location.longitude)
                        )
                    }
                }
                .navigationTitle("Edit Saved Item")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            editingLocation = nil
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.updateItem(
                                id: location.id,
                                newName: editedName,
                                newNotes: editedNotes
                            )
                            editingLocation = nil
                        }
                        .disabled(
                            editedName.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        )
                    }
                }
            }
            .presentationDetents([.medium])
        }

        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            locationViewModel.stopLocationUpdates()
        }
    }
    private var filteredLocations: [SavedLocation] {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else {
            return viewModel.savedLocations
        }

        return viewModel.savedLocations.filter { location in
            location.itemName.localizedCaseInsensitiveContains(query)
            || location.notes.localizedCaseInsensitiveContains(query)
        }
    }
}

#Preview {
    NavigationStack {
        SavedLocationsView()
    }
}
