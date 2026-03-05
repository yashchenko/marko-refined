//
//  Array+Ext.swift
//  Marko
//
//  Created by Ivan on 02.03.2026.
//

import Foundation

extension Array where Element == Lesson {
    
    var upcoming: [Lesson] {
        
        return self.filter { lesson -> Bool in
            lesson.status == .upcoming && !lesson.hasEnded
        } .sorted { $0.startTime < $1.startTime }
    }
    
    var completed: [Lesson] {
        
        return self.filter { $0.status == .completed }
            .sorted { $0.startTime > $1.startTime }
    }
    
    // Фильтрует только отменённые уроки
    var cancelled: [Lesson] {
        return self.filter {
            $0.status == .cancelledByStudent ||
                $0.status == .cancelledByTeacher
        }
        .sorted { $0.startTime > $1.startTime }
    }
    
    // Фильтрует уроки, которые начинаются сегодня
    var today: [Lesson] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
            return []
        }
        
        return self.filter { lesson in
            lesson.startTime >= today && lesson.startTime < tomorrow
        }
        .sorted { $0.startTime < $1.startTime }
    }
    
    // Фильтрует уроки, которые начинаются на этой неделе
    var thisWeek: [Lesson] {
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else {
            return []
        }
        
        return self.filter { lesson in
            lesson.startTime >= weekStart && lesson.startTime < weekEnd
        }
        .sorted { $0.startTime < $1.startTime }
    }
}
