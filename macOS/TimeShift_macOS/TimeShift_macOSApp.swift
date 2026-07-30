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
            ContentView_macOS()
                .modelContainer(modelContainer)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1000, height: 700)
    }
}
