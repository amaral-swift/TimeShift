//
//  PreviewData.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import Foundation
import SwiftData

/// Dados e container em memória usados em `#Preview` (e, futuramente, em testes
/// de UI). Nada aqui toca o SwiftData "de verdade" do usuário.
@MainActor
enum PreviewData {
    static let sampleCities: [WorldCity] = [
        WorldCity(name: "San Francisco", timeZoneIdentifier: "America/Los_Angeles", sortOrder: 0, isPrimary: true),
        WorldCity(name: "Rome", timeZoneIdentifier: "Europe/Rome", sortOrder: 1),
        WorldCity(name: "Cairo", timeZoneIdentifier: "Africa/Cairo", sortOrder: 2),
        WorldCity(name: "London", timeZoneIdentifier: "Europe/London", sortOrder: 3),
    ]

    /// `ModelContainer` em memória, pré-populado com `sampleCities`.
    static var container: ModelContainer = {
        let schema = Schema([WorldCity.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        for city in sampleCities {
            container.mainContext.insert(city)
        }
        return container
    }()
}
