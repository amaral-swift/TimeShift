//
//  CitySearchView.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI
import SwiftData

struct CitySearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Query private var existingCities: [WorldCity]

    @State private var searchText = ""
    @State private var results: [GeocodingResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            List(results) { result in
                CityResultRow(result: result, isAdded: isAlreadyAdded(result)) {
                    addCity(result: result)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AccentGradient.background(for: colorScheme).ignoresSafeArea())
            .navigationTitle("Adicionar cidade")
            #if os(iOS) || os(iPadOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .searchable(text: $searchText, prompt: "Buscar cidade")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .overlay {
                statusOverlay
            }
            .onChange(of: searchText) { _, newValue in
                scheduleSearch(for: newValue)
            }
        }
    }

    @ViewBuilder
    private var statusOverlay: some View {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            ContentUnavailableView("Buscar cidade", systemImage: "magnifyingglass", description: Text("Digite o nome de uma cidade, ex.: Tóquio, Rome, New York"))
        } else if isLoading {
            ProgressView()
        } else if let errorMessage {
            ContentUnavailableView("Não foi possível buscar", systemImage: "wifi.slash", description: Text(errorMessage))
        } else if results.isEmpty {
            ContentUnavailableView.search
        }
    }

    private func scheduleSearch(for query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            errorMessage = nil
            isLoading = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            isLoading = true
            errorMessage = nil
            do {
                let fetched = try await GeocodingService.search(name: trimmed)
                guard !Task.isCancelled else { return }
                results = fetched
            } catch {
                guard !Task.isCancelled else { return }
                results = []
                errorMessage = "Verifique sua conexão e tente novamente."
            }
            isLoading = false
        }
    }

    private func isAlreadyAdded(_ result: GeocodingResult) -> Bool {
        existingCities.contains { $0.timeZoneIdentifier == result.timezone }
    }

    private func addCity(result: GeocodingResult) {
        guard !isAlreadyAdded(result) else { return }
        let nextOrder = (existingCities.map(\.sortOrder).max() ?? -1) + 1
        let city = WorldCity(name: result.name, timeZoneIdentifier: result.timezone, sortOrder: nextOrder)
        modelContext.insert(city)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    CitySearchView()
        .modelContainer(PreviewData.container)
}
