//
//  ContentView.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 28/07/26.
//

import SwiftUI
import SwiftData

struct ContentViewiOS: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
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
            .scrollContentBackground(.hidden)
            .background(AccentGradient.background(for: colorScheme).ignoresSafeArea())
            #if os(iOS) || os(iPadOS)
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
            #endif
            .navigationTitle("Fusus")
            .toolbar {
                #if os(iOS) || os(iPadOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button(isEditing ? "Concluído" : "Editar") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Adicionar cidade", systemImage: "plus") {
                        isAddingCity = true
                    }
                    .disabled(isEditing)
                }
                #endif
            }
            .sheet(isPresented: $isAddingCity) {
                CitySearchView()
            }
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
        try? modelContext.save()
    }

    private func deleteCities(at offsets: IndexSet) {
        offsets.map { cities[$0] }.forEach(delete)
    }
}

#Preview {
    ContentViewiOS()
        .modelContainer(PreviewData.container)
}
