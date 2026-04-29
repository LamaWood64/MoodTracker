//
//  MoodSelectionViewModel.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.
//

import Foundation
import Combine

class MoodSelectionViewModel: ObservableObject {
    
    private let storageKey = "mood_entries"
    
    @Published var selectedMood: Int? = nil
    @Published var moodEntries: [MoodEntry] = []
    
    init() {
        load()
        notificationService.requestPermission()
        notificationService.scheduleDailyReminder()
        cleanUpOldEntriesIfNeeded()
    }
    
    func selectMood(_ mood: Int) {
        selectedMood = mood
    }
    
    func saveMood() {
        guard let mood = selectedMood else { return }
        
        let entry = MoodEntry(
            id: UUID(),
            date: Date(),
            value: mood
        )
        
        moodEntries.append(entry)
        persist()
        selectedMood = nil
    }
    
    func entries(for date: Date) -> [MoodEntry] {
        let targetDay = Calendar.current.startOfDay(for: date)
        return moodEntries.filter { entry in
            Calendar.current.startOfDay(for: entry.date) == targetDay
        }.sorted { $0.date < $1.date }
    }
    
    func averageMood(for date: Date) -> Double? {
        let entries = entries(for: date)
        guard !entries.isEmpty else { return nil }
        let sum = entries.reduce(0) { $0 + $1.value }
        return Double(sum) / Double(entries.count)
    }
    
    // MARK: - Computed Properties для Analytics
    
    var moodByDay: [(date: Date, mood: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: moodEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        return grouped.map { (date, entries) in
            let average = Double(entries.reduce(0) { $0 + $1.value }) / Double(entries.count)
            return (date: date, mood: average)
        }.sorted { $0.date < $1.date }
    }
    

    var dailyMoodTrend: [(time: Date, mood: Int)] {
        return moodEntries.map { (time: $0.date, mood: $0.value) }
            .sorted { $0.time < $1.time }
    }
    
    var moodByWeek: [(weekStart: Date, mood: Double)] {
        let calendar = Calendar.current
        
        let dailyAverages = moodByDay

        let grouped = Dictionary(grouping: dailyAverages) { item in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: item.date)) ?? item.date
        }
        
        return grouped.map { (weekStart, dailyItems) in
            let average = dailyItems.reduce(0) { $0 + $1.mood } / Double(dailyItems.count)
            return (weekStart: weekStart, mood: average)
        }.sorted { $0.weekStart < $1.weekStart }
    }
    

    var moodByMonth: [(monthStart: Date, mood: Double)] {
        let calendar = Calendar.current
        
        let dailyAverages = moodByDay
        
        let grouped = Dictionary(grouping: dailyAverages) { item in
            calendar.date(from: calendar.dateComponents([.year, .month], from: item.date)) ?? item.date
        }
        
        return grouped.map { (monthStart, dailyItems) in
            let average = dailyItems.reduce(0) { $0 + $1.mood } / Double(dailyItems.count)
            return (monthStart: monthStart, mood: average)
        }.sorted { $0.monthStart < $1.monthStart }
    }
    
    var overallAverageMood: Double {
        guard !moodEntries.isEmpty else { return 0 }
        let sum = moodEntries.reduce(0) { $0 + $1.value }
        return Double(sum) / Double(moodEntries.count)
    }
    
    var bestDay: (date: Date, mood: Double)? {
        guard let best = moodByDay.max(by: { $0.mood < $1.mood }) else { return nil }
        return (date: best.date, mood: best.mood)
    }
    
    var worstDay: (date: Date, mood: Double)? {
        guard let worst = moodByDay.min(by: { $0.mood < $1.mood }) else { return nil }
        return (date: worst.date, mood: worst.mood)
    }
    
    var totalEntries: Int {
        moodEntries.count
    }
    
    var streakDays: Int {
        calculateStreak()
    }
    
    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let daysWithEntries = Set(moodEntries.map { calendar.startOfDay(for: $0.date) })
        let sortedDays = daysWithEntries.sorted(by: >)
        
        var streak = 0
        let today = calendar.startOfDay(for: Date())
        
        for (index, day) in sortedDays.enumerated() {
            let expectedDate = calendar.date(byAdding: .day, value: -index, to: today) ?? today
            
            if calendar.isDate(day, inSameDayAs: expectedDate) {
                streak += 1
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func cleanUpOldEntriesIfNeeded() {
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        let oldCount = moodEntries.filter { $0.date < oneYearAgo }.count
        
        if oldCount > 0 {
            moodEntries.removeAll { $0.date < oneYearAgo }
            persist()
        }
    }
    
    private func persist() {
        do {
            let data = try JSONEncoder().encode(moodEntries)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving:", error)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        
        do {
            moodEntries = try JSONDecoder().decode([MoodEntry].self, from: data)
        } catch {
            print("Error loading:", error)
        }
    }
    
    private let notificationService = NotificationService()
}
