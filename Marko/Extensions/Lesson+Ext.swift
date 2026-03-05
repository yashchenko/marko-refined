//
//  Lesson+Ext.swift
//  Marko
//
//  Created by Ivan on 20.02.2026.
//

import UIKit

extension Lesson {
    
    // formatted date for UI
    var formattedFullDateTime: String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    // short date for compact view
    var formattedDateShortTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, HH:mm"
        return formatter.string(from: startTime)
    }
    
    // duration the lesson in hours
    var durationInHours: Double {
        return endTime.timeIntervalSince(startTime) / 3600
    }
    
    
    
    // duration as a String, example: "1h" или "1.5h"
    var formattedDuration: String {
        
        let hours = durationInHours
        
        if hours == floor(hours) {
            return "\(Int(hours))h"
        } else {
            return String(format: "%.1fh", hours)
        }
    }
    
    // check whether the lesson starts in the next N min
    
    func isStartingSoon(withinMinutes minutes: Int = 15) -> Bool {
        let now = Date()
        let timeUntilStart = startTime.timeIntervalSince(now)
        return timeUntilStart > 0 && timeUntilStart <= Double(minutes * 60)
    }
    
    // check whether the lesson happening right now
    
    var isHappeningNow: Bool {
        
        let now = Date()
        return now >= startTime && now <= endTime
        
    }
    
    // check whether lesson is end
    var hasEnded: Bool {
        
        return Date() > endTime
        
    }
    
    // return status of lesson in readable way
    var statusText: String {
        
        switch status {
        case .upcoming:
            return "Upcoming"
        case .completed:
            return "Completed"
        case .cancelledByStudent:
            return "Cancelled by You"
        case .cancelledByTeacher:
            return "Cancelled by Teacher"
        }
        
    }
    
    // colour for statuses (can use for badge)
    var statusColor: UIColor {
        
        switch status {
        case .upcoming:
            return .systemGreen
        case .completed:
            return .systemGray
        case .cancelledByStudent, .cancelledByTeacher:
            return .systemRed
        }
    }
    
    // background colour (semiopaque)
    var statusBackGroundColour: UIColor {
        
        return statusColor.withAlphaComponent(0.15)
    }
    
}
