//
//  TimeShiftViewModel.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import Foundation
import Observation

@Observable
final class TimeShiftViewModel {
    var cities: [WorldCity] = []
    
    var referenceDate: Date = .now
    
    var draggingCityID: UUID?
    
    private var liveClockTask: Task<Void, Never>?
    
    init(cities: [WorldCity] = []) {
        self.cities = cities
        startLiveClock()
    }
    
    private func startLiveClock() {
        liveClockTask = Task {
            while !Task.isCancelled {
                if draggingCityID == nil {
                    referenceDate = .now
                }
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
    
    func fraction(for city: WorldCity) -> Double {
        let calendar = Calendar.current
        var cal = calendar
        cal.timeZone = city.timeZone
        let components = cal.dateComponents([.hour, .minute, .second], from: referenceDate)
        let seconds = Double(components.hour ?? 0) * 3600 + Double(components.minute ?? 0) * 60 + Double(components.second ?? 0)
        return seconds / 86_400
    }
    
    func updateReferenceDate(draggedCity: WorldCity, toFraction fraction: Double) {
        draggingCityID = draggedCity.id
        let clamped = min(max(fraction, 0), 1)
        let totalSeconds = clamped * 86_400
        
        var cal = Calendar.current
        cal.timeZone = draggedCity.timeZone
        let startOfDay = cal.startOfDay(for: referenceDate)
        referenceDate = startOfDay.addingTimeInterval(totalSeconds)
    }
    
    func endDragging() {
        draggingCityID = nil
    }
}
