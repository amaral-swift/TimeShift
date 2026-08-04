//
//  TimeShift_macOSApp.swift
//  TimeShift_macOS
//
//  Created by Gabriel Amaral on 30/07/26.
//

import SwiftUI
import SwiftData

@main
struct TimeShiftApp_macOS: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: WorldCity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentViewMacOS()
                .modelContainer(modelContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1000, height: 700)
        
        MenuBarExtra("Fusus", systemImage: "clock") {
            MenuBarContentView()
                .modelContainer(modelContainer)
                .frame(width: 500, height: 300)
        }
        .menuBarExtraStyle(.window)
    }
}
