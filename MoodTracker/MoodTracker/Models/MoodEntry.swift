//
//  MoodEntry.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.

import Foundation

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let value: Int
    
    var dayStart: Date {
        Calendar.current.startOfDay(for: date)
    }
    
    var weekStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) ?? date
    }
    
    var monthStart: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: date)) ?? date
    }
}
