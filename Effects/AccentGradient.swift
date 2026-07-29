//
//  AccentGradient.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import SwiftUI

enum AccentGradient {
    static let start = Color(red: 0.18, green: 0.90, blue: 0.77)
    static let end = Color(red: 0.30, green: 0.44, blue: 1.0)

    static var background: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.02, green: 0.07, blue: 0.07),
                Color(red: 0.03, green: 0.03, blue: 0.09),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
