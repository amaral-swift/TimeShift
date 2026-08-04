//
//  MenuBarContentView.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 04/08/26.
//

import SwiftUI
import SwiftData

struct MenuBarContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorldCity.sortOrder) private var cities: [WorldCity]

    @State private var viewModel = TimeShiftViewModel()
    @State private var isEditing = false
    
    var body: some View {
        List {
            ForEach(cities) { city in
                CityRow(city: city, viewModel: viewModel, isEditing: isEditing, onDelete: delete)
            }
        }
    }
    
    private func delete(_ city: WorldCity) {
        modelContext.delete(city)
    }
}

#Preview {
    MenuBarContentView()
}
