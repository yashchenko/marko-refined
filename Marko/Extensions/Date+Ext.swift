//
//  Date+Ext.swift
//  Marko
//
//  Created by Ivan on 05.03.2026.
//

import Foundation

extension Date {
    
    // check whether the daye is today
    var isToday:Bool {
        
        return Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        
        return Calendar.current.isDateInTomorrow(self)
    }
    
    var relativeDescription: String {
        
        if isToday {
            return "Today"
        } else {
            if isTomorrow {
            return "Tommorow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: self)
            }
        }
    }
}
