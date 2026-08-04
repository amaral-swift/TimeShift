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
        self = switch hour {
        case 0..<5: .night
        case 5..<7: .dawn
        case 7..<12: .morning
        case 12..<18: .afternoon
        default: .evening
        }
    }
}
