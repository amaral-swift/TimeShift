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
    /// `false` no modo edição — desliga o arraste de horário pra não brigar
    /// com o gesto de reordenar/apagar que o ContentView ativa nesse modo.
    var isInteractive: Bool = true
    @State private var dragFraction: Double?

    // App fixado em 24h — sem toggle de formato por enquanto.
    private let use24Hour = true

    private let cornerRadius: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let fraction = dragFraction ?? viewModel.fraction(for: city)
            let period = DayPeriod(hour: Int(fraction * 24))
            
            ZStack(alignment: .leading) {
                CityCardBackground(fraction: fraction)
                    .animation(
                        viewModel.draggingCityID == city.id ? nil : .easeInOut(duration: 0.6),
                        value: fraction
                    )

                Rectangle()
                    .fill(.white.opacity(0.18))
                    .frame(width: geo.size.width * fraction)
                    .animation(.smooth(duration: 0.25), value: fraction)

                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.headline)
                    Text(formattedTime())
                        .font(.system(size: 40, weight: .semibold, design: .rounded))
                        .contentTransition(.numericText())
                }
                .padding()
            }
            // Recorta o conteúdo do ZStack (gradiente + preenchimento) para a
            // mesma forma usada pelo glassEffect — sem isso, o glassEffect só
            // desenha o material de vidro nessa forma, mas não recorta o que
            // está por baixo, e o retângulo do gradiente "vaza" pelos cantos.
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let fraction = value.location.x / geo.size.width
                        dragFraction = min(max(fraction, 0), 1)
                        viewModel.updateReferenceDate(draggedCity: city, toFraction: dragFraction!)
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
        .frame(height: 120)
    }

    private func formattedTime() -> String {
        city.timeZone.formattedTime(from: viewModel.referenceDate, use24Hour: use24Hour)
    }
}
