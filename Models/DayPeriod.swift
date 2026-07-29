//
//  DayPeriod.swift
//  TimeShift
//
//  Created by Gabriel Amaral on 29/07/26.
//

import Foundation

enum DayPeriod {
    case night, dawn, morning, afternoon, evening
    
    init(hour: Int) {
        switch hour {
        case 0..<5: self = .night
        case 5..<7: self = .dawn
        case 7..<12: self = .morning
        case 12..<18: self = .afternoon
        default: self = .evening
            
        }
    }
}
