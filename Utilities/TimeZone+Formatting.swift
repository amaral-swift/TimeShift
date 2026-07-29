//
//  TimeZone+Formatting.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import Foundation

extension TimeZone {
    func formattedTime(from date: Date, use24Hour: Bool) -> String {
        var style = Date.FormatStyle(timeZone: self)
        style = use24Hour
            ? style.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)
            : style.hour(.defaultDigits(amPM: .abbreviated)).minute(.twoDigits)
        return date.formatted(style)
    }

    func shortLabel(at date: Date = .now, locale: Locale = .current) -> String {
        if let abbreviation = self.abbreviation(for: date) {
            return abbreviation
        }
        let seconds = secondsFromGMT(for: date)
        let hours = seconds / 3600
        return "GMT\(hours >= 0 ? "+" : "")\(hours)"
    }
}
