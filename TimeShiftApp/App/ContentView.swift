//
//  ContentView.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 28/07/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorldCity.sortOrder) private var cities: [WorldCity]

    @State private var viewModel = TimeShiftViewModel()
    @State private var isAddingCity = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cities) { city in
                        CityCardView(city: city, viewModel: viewModel)
                    }
                }
                .padding()
            }
            .background(Color.black.opacity(0.92))
            .navigationTitle("TimeShift")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingCity = true
                    } label: {
                        Label("Adicionar cidade", systemImage: "plus")
                    }
                }
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
}

#Preview {
    ContentView()
        .modelContainer(PreviewData.container)
}
