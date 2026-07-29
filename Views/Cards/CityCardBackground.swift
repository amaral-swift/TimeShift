//
//  CityCardBackground.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI

struct CityCardBackground: View {
    let fraction: Double

    var body: some View {
        LinearGradient(
            colors: [topColor, bottomColor],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(
            LinearGradient(
                colors: [.black.opacity(0), .black.opacity(0.22)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var hour: Double {
        min(max(fraction, 0), 1) * 24
    }

    private var topColor: Color { DayPalette.color(atHour: hour, layer: .top) }
    private var bottomColor: Color { DayPalette.color(atHour: hour, layer: .bottom) }
}

private enum DayPalette {
    enum Layer { case top, bottom }

    private struct Anchor {
        let hour: Double
        let top: (r: Double, g: Double, b: Double)
        let bottom: (r: Double, g: Double, b: Double)
    }

    private static let anchors: [Anchor] = [
        Anchor(hour: 0,  top: (0.04, 0.05, 0.14), bottom: (0.09, 0.10, 0.24)),
        Anchor(hour: 5,  top: (0.10, 0.11, 0.26), bottom: (0.30, 0.22, 0.38)),
        Anchor(hour: 7,  top: (0.95, 0.55, 0.35), bottom: (0.98, 0.75, 0.45)),
        Anchor(hour: 10, top: (0.35, 0.60, 0.92), bottom: (0.55, 0.78, 0.97)),
        Anchor(hour: 14, top: (0.30, 0.55, 0.90), bottom: (0.50, 0.72, 0.95)),
        Anchor(hour: 17, top: (0.95, 0.55, 0.30), bottom: (0.85, 0.35, 0.40)),
        Anchor(hour: 19, top: (0.35, 0.20, 0.45), bottom: (0.55, 0.25, 0.40)),
        Anchor(hour: 21, top: (0.08, 0.08, 0.20), bottom: (0.18, 0.14, 0.32)),
        Anchor(hour: 24, top: (0.04, 0.05, 0.14), bottom: (0.09, 0.10, 0.24)),
    ]

    static func color(atHour hour: Double, layer: Layer) -> Color {
        let clamped = min(max(hour, 0), 24)

        guard let upperIndex = anchors.firstIndex(where: { $0.hour >= clamped }),
              upperIndex > 0 else {
            let c = layer == .top ? anchors[0].top : anchors[0].bottom
            return Color(red: c.r, green: c.g, blue: c.b)
        }

        let lower = anchors[upperIndex - 1]
        let upper = anchors[upperIndex]
        let range = upper.hour - lower.hour
        let t = range == 0 ? 0 : (clamped - lower.hour) / range

        let a = layer == .top ? lower.top : lower.bottom
        let b = layer == .top ? upper.top : upper.bottom

        return Color(
            red: lerp(a.r, b.r, t),
            green: lerp(a.g, b.g, t),
            blue: lerp(a.b, b.b, t)
        )
    }

    private static func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * t
    }
}

#Preview("Ciclo do dia") {
    HStack(spacing: 8) {
        ForEach([0.0, 0.22, 0.3, 0.45, 0.6, 0.72, 0.85, 0.95], id: \.self) { f in
            CityCardBackground(fraction: f)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    .padding()
}
