//
//  CityRow.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI

struct CityRow: View {
    let city: WorldCity
    var viewModel: TimeShiftViewModel
    let isEditing: Bool
    let onDelete: (WorldCity) -> Void

    var body: some View {
        CityCardView(city: city, viewModel: viewModel, isInteractive: !isEditing)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Apagar", systemImage: "trash", role: .destructive) {
                    onDelete(city)
                }
            }
    }
}
