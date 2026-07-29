//
//  WorldCity.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import Foundation
import SwiftData

@Model
final class WorldCity {
    var id: UUID
    var name: String
    var timeZoneIdentifier: String
    var sortOrder: Int
    var isPrimary: Bool
    
    init(name: String, timeZoneIdentifier: String, sortOrder: Int, isPrimary: Bool = false) {
        self.id = UUID()
        self.name = name
        self.timeZoneIdentifier = timeZoneIdentifier
        self.sortOrder = sortOrder
        self.isPrimary = isPrimary
    }
    
    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? . current
    }
}
