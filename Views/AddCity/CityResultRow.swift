//
//  CityResultRow.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI

struct CityResultRow: View {
    let result: GeocodingResult
    let isAdded: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.name)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isAdded {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .disabled(isAdded)
    }

    private var subtitle: String {
        [result.admin1, result.country].compactMap { $0 }.joined(separator: ", ")
    }
}
