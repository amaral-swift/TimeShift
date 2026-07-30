//
//  AccentGradient.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI

enum AccentGradient {
    private static let darkColors = [
        Color(red: 0.02, green: 0.07, blue: 0.07),
        Color(red: 0.03, green: 0.03, blue: 0.09),
    ]

    private static let lightColors = [
        Color(red: 0.90, green: 0.99, blue: 0.97),
        Color(red: 0.92, green: 0.93, blue: 1.0),
    ]

    static func background(for scheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: scheme == .dark ? darkColors : lightColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
