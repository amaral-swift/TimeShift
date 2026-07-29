//
//  CitySearchView.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI
import SwiftData

/// Sheet de busca e adição de cidade.
///
/// Usa `TimeZone.knownTimeZoneIdentifiers` como fonte de dados — não depende
/// de rede nem de permissão de localização (a alternativa com MapKit /
/// `MKLocalSearchCompleter` citada no ARCHITECTURE.md fica como upgrade
/// futuro, se algum dia precisarmos de busca por endereço de verdade).
struct CitySearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingCities: [WorldCity]

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List(filteredIdentifiers, id: \.self) { identifier in
                Button {
                    addCity(identifier: identifier)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(displayName(for: identifier))
                                .foregroundStyle(.primary)
                            Text(identifier)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if isAlreadyAdded(identifier) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .disabled(isAlreadyAdded(identifier))
            }
            .navigationTitle("Adicionar cidade")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Buscar cidade ou fuso")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .overlay {
                if filteredIdentifiers.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
        }
    }

    /// Sem busca, mostra uma lista curta pra não jogar milhares de fusos na
    /// tela de cara. Com busca, filtra por identificador ("America/New_York")
    /// e pelo nome derivado dele ("New York").
    private var filteredIdentifiers: [String] {
        let all = TimeZone.knownTimeZoneIdentifiers.sorted()
        guard !searchText.isEmpty else { return Array(all.prefix(40)) }
        return all.filter {
            $0.localizedCaseInsensitiveContains(searchText)
                || displayName(for: $0).localizedCaseInsensitiveContains(searchText)
        }
    }

    private func displayName(for identifier: String) -> String {
        identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier
    }

    private func isAlreadyAdded(_ identifier: String) -> Bool {
        existingCities.contains { $0.timeZoneIdentifier == identifier }
    }

    private func addCity(identifier: String) {
        guard !isAlreadyAdded(identifier) else { return }
        let nextOrder = (existingCities.map(\.sortOrder).max() ?? -1) + 1
        let city = WorldCity(name: displayName(for: identifier), timeZoneIdentifier: identifier, sortOrder: nextOrder)
        modelContext.insert(city)
        dismiss()
    }
}

#Preview {
    CitySearchView()
        .modelContainer(PreviewData.container)
}
