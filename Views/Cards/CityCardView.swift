//
//  CityCardView.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI

struct CityCardView: View {
    let city: WorldCity
    @Bindable var viewModel: TimeShiftViewModel
    var isInteractive: Bool = true
    @State private var dragFraction: Double?
    @State private var cardWidth: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let use24Hour = true

    private let cornerRadius: CGFloat = 24

    var body: some View {
        let fraction = dragFraction ?? viewModel.fraction(for: city)

        ZStack(alignment: .leading) {
            CityCardBackground(fraction: fraction)
                .animation(
                    reduceMotion || viewModel.draggingCityID == city.id ? nil : .easeInOut(duration: 0.6),
                    value: fraction
                )

            Rectangle()
                .fill(.white.opacity(0.18))
                .frame(width: cardWidth * fraction)
                .animation(reduceMotion ? nil : .smooth(duration: 0.25), value: fraction)

            VStack(alignment: .leading, spacing: 4) {
                Text(city.name)
                    .font(.headline)
                Text(formattedTime())
                    .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            .padding()
        }
        .frame(height: 120)
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { newValue in
            cardWidth = newValue
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        .gesture(
            DragGesture(minimumDistance: 12)
                .onChanged { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    guard cardWidth > 0 else { return }
                    let clamped = min(max(value.location.x / cardWidth, 0), 1)
                    dragFraction = clamped
                    viewModel.updateReferenceDate(draggedCity: city, toFraction: clamped)
                }
                .onEnded { _ in
                    dragFraction = nil
                    viewModel.endDragging()
                },
            isEnabled: isInteractive
        )
        .opacity(isInteractive ? 1 : 0.85)
        .sensoryFeedback(.selection, trigger: Int(fraction * 24))
    }

    private func formattedTime() -> String {
        city.timeZone.formattedTime(from: viewModel.referenceDate, use24Hour: use24Hour)
    }
}
