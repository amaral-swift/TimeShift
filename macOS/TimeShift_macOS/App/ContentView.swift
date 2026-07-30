//
//  ContentView.swift
//  TimeShift_macOS
//
//  Created by Gabriel Amaral on 30/07/26.
//

import SwiftUI
import SwiftData

struct ContentView_macOS: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorldCity.sortOrder) private var cities: [WorldCity]

    @State private var viewModel = TimeShiftViewModel()
    @State private var isAddingCity = false
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(cities) { city in
                    CityRow(city: city, viewModel: viewModel, isEditing: isEditing, onDelete: delete)
                }
                .onMove(perform: moveCities)
                .onDelete(perform: deleteCities)
            }
            .listStyle(.plain)
            .navigationTitle("TimeShift")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isAddingCity = true }) {
                        Label("Adicionar", systemImage: "plus")
                    }
                    .disabled(isEditing)
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button(isEditing ? "Concluído" : "Editar") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isAddingCity) {
            CitySearchView()
                .presentationSizing(.page)
        }
        .task {
            seedInitialCitiesIfNeeded()
        }
    }
    
    private func seedInitialCitiesIfNeeded() {
        guard cities.isEmpty else { return }
        let defaults = [
            WorldCity(name: "San Francisco", timeZoneIdentifier: "America/Los_Angeles", sortOrder: 0, isPrimary: true),
            WorldCity(name: "Rome", timeZoneIdentifier: "Europe/Rome", sortOrder: 1),
            WorldCity(name: "Cairo", timeZoneIdentifier: "Africa/Cairo", sortOrder: 2),
            WorldCity(name: "London", timeZoneIdentifier: "Europe/London", sortOrder: 3),
        ]
        defaults.forEach { modelContext.insert($0) }
    }
    
    private func moveCities(from source: IndexSet, to destination: Int) {
        var reordered = cities
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, city) in reordered.enumerated() {
            city.sortOrder = index
        }
    }

    private func delete(_ city: WorldCity) {
        modelContext.delete(city)
    }

    private func deleteCities(at offsets: IndexSet) {
        offsets.map { cities[$0] }.forEach(delete)
    }
}

#Preview {
    ContentView_macOS()
        .modelContainer(PreviewData.container)
}
