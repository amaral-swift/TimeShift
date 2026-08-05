//
//  ContentView.swift
//  TimeShift_macOS
//
//  Created by Gabriel Amaral on 30/07/26.
//

import SwiftUI
import SwiftData

struct ContentViewMacOS: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorldCity.sortOrder) private var cities: [WorldCity]

    @State private var viewModel = TimeShiftViewModel()
    @State private var isAddingCity = false
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(cities) { city in
                    HStack(spacing: 12) {
                        if isEditing {
                            Button("Remover \(city.name)", systemImage: "minus.circle.fill") {
                                withAnimation {
                                    delete(city)
                                }
                            }
                            .labelStyle(.iconOnly)
                            .buttonStyle(.plain)
                            .foregroundStyle(.red)
                            .font(.title2)
                            .frame(minWidth: 44, minHeight: 44)
                            .contentShape(.rect)
                            .transition(.opacity.combined(with: .scale))
                        }
                        CityRow(city: city, viewModel: viewModel, isEditing: isEditing, onDelete: delete)
                    }
                }
                .onMove(perform: moveCities)
                .onDelete(perform: deleteCities)
            }
            .listStyle(.plain)
            .navigationTitle("Fusus")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(isEditing ? "Concluído" : "Editar") {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                    
                    Button("Adicionar", systemImage: "plus") {
                        isAddingCity = true
                    }
                    .disabled(isEditing)
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
        try? modelContext.save()
    }

    private func deleteCities(at offsets: IndexSet) {
        offsets.map { cities[$0] }.forEach(delete)
    }
}

#Preview {
    ContentViewMacOS()
        .modelContainer(PreviewData.container)
}
