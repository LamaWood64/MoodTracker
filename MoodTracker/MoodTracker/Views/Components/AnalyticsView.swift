//
//  AnalyticsView.swift
//  MoodTracker
//
//  Created by Anastasia on 28.04.26.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var viewModel: MoodSelectionViewModel
    @State private var selectedTab = 0
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.purple.opacity(0.5), .blue.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                StatsHeader(viewModel: viewModel)
                
                Picker("Period", selection: $selectedTab) {
                    Text("Days").tag(0)
                    Text("Weeks").tag(1)
                    Text("Months").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .background(.ultraThinMaterial)
                
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case 0:
                           
                            DailyMoodChart(viewModel: viewModel)
                        case 1:
                            WeeksChartView(viewModel: viewModel)
                        default:
                            MonthsChartView(viewModel: viewModel)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Daily Mood Chart (показывает изменения в течение дня)

struct DailyMoodChart: View {
    @ObservedObject var viewModel: MoodSelectionViewModel
    @State private var selectedDateString: String = ""
    @State private var isInitialized = false
    
    var availableDates: [(date: Date, string: String)] {
        let dates = Set(viewModel.moodEntries.map { Calendar.current.startOfDay(for: $0.date) })
        return Array(dates)
            .sorted(by: >)
            .map { date in
                (date: date, string: formatDate(date))
            }
    }
    
    var entriesForSelectedDate: [(time: Date, mood: Int)] {
        guard !selectedDateString.isEmpty else { return [] }
        
        guard let selectedDate = availableDates.first(where: { $0.string == selectedDateString })?.date else {
            return []
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        return viewModel.moodEntries
            .filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            .map { (time: $0.date, mood: $0.value) }
            .sorted { $0.time < $1.time }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if !availableDates.isEmpty {

                if isInitialized {
                    Picker("Select Date", selection: $selectedDateString) {
                        ForEach(availableDates, id: \.string) { item in
                            Text(item.string).tag(item.string)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                } else {

                    ProgressView()
                        .padding()
                        .onAppear {
                            if let latest = availableDates.first {
                                selectedDateString = latest.string
                                isInitialized = true
                            }
                        }
                }
            }
            
            if !selectedDateString.isEmpty && !entriesForSelectedDate.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Mood Changes During Day")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(selectedDateString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Chart {
                        ForEach(entriesForSelectedDate.indices, id: \.self) { index in
                            let entry = entriesForSelectedDate[index]
                            
                            LineMark(
                                x: .value("Time", entry.time),
                                y: .value("Mood", entry.mood)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .interpolationMethod(.linear)
                            .lineStyle(StrokeStyle(lineWidth: 3))
                            
                            PointMark(
                                x: .value("Time", entry.time),
                                y: .value("Mood", entry.mood)
                            )
                            .foregroundStyle(Color.white)
                            .symbolSize(100)
                            
                            PointMark(
                                x: .value("Time", entry.time),
                                y: .value("Mood", entry.mood)
                            )
                            .annotation(position: .top) {
                                Text("\(entry.mood)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(Color.blue.opacity(0.9))
                                            .frame(width: 28, height: 28)
                                    )
                            }
                            .foregroundStyle(.clear)
                        }
                    }
                    .frame(height: 320)
                    .chartYScale(domain: 0.5...5.5)
                    .chartXScale(domain: getTimeRange())
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(.white.opacity(0.3))
                            AxisValueLabel(format: .dateTime.hour().minute())
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(.white.opacity(0.3))
                            AxisValueLabel()
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    
                    HStack {
                        StatBadge(
                            title: "Average",
                            value: String(format: "%.1f", averageMood()),
                            color: .cyan
                        )
                        StatBadge(
                            title: "Entries",
                            value: "\(entriesForSelectedDate.count)",
                            color: .blue
                        )
                        StatBadge(
                            title: "Range",
                            value: moodRange(),
                            color: .purple
                        )
                        StatBadge(
                            title: "Change",
                            value: moodChange(),
                            color: .green
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Timeline")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        ForEach(entriesForSelectedDate, id: \.time) { entry in
                            HStack {
                                Text(formatTime(entry.time))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                    .frame(width: 70, alignment: .leading)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: CGFloat(entry.mood) * 20, height: 8)
                                    .cornerRadius(4)
                                
                                Text("Mood: \(entry.mood)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.1))
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
            } else if !availableDates.isEmpty && isInitialized {
                EmptyStateView(message: "No entries for this day")
            } else if availableDates.isEmpty {
                EmptyStateView(message: "No mood entries yet")
            }
        }
    }
    
    private func getTimeRange() -> ClosedRange<Date> {
        guard let first = entriesForSelectedDate.first?.time,
              let last = entriesForSelectedDate.last?.time else {
            let defaultStart = Calendar.current.startOfDay(for: Date())
            let defaultEnd = defaultStart.addingTimeInterval(86400)
            return defaultStart...defaultEnd
        }
        
        let start = first.addingTimeInterval(-3600)
        let end = last.addingTimeInterval(3600)
        
        return start...end
    }
    
    private func averageMood() -> Double {
        guard !entriesForSelectedDate.isEmpty else { return 0 }
        let sum = entriesForSelectedDate.reduce(0) { $0 + $1.mood }
        return Double(sum) / Double(entriesForSelectedDate.count)
    }
    
    private func moodRange() -> String {
        let moods = entriesForSelectedDate.map { $0.mood }
        guard let min = moods.min(), let max = moods.max() else { return "—" }
        if min == max {
            return "\(min)"
        }
        return "\(min) → \(max)"
    }
    
    private func moodChange() -> String {
        guard let first = entriesForSelectedDate.first?.mood,
              let last = entriesForSelectedDate.last?.mood else {
            return "—"
        }
        if first == last {
            return "→ \(first)"
        }
        return first < last ? "↑ \(first) → \(last)" : "↓ \(first) → \(last)"
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white.opacity(0.1))
        )
    }
}

// MARK: - Weeks Chart
struct WeeksChartView: View {
    @ObservedObject var viewModel: MoodSelectionViewModel
    
    var body: some View {
        if viewModel.moodByWeek.isEmpty {
            EmptyStateView(message: "No weekly data yet")
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Weekly Average Mood")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Based on daily averages")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Chart(viewModel.moodByWeek, id: \.weekStart) { item in
                    BarMark(
                        x: .value("Week", item.weekStart, unit: .weekOfYear),
                        y: .value("Mood", item.mood)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
                .frame(height: 250)
                .chartYScale(domain: 0.5...5.5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Months Chart
struct MonthsChartView: View {
    @ObservedObject var viewModel: MoodSelectionViewModel
    
    var body: some View {
        if viewModel.moodByMonth.isEmpty {
            EmptyStateView(message: "No monthly data yet")
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Monthly Average Mood")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Based on daily averages")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Chart(viewModel.moodByMonth, id: \.monthStart) { item in
                    AreaMark(
                        x: .value("Month", item.monthStart, unit: .month),
                        y: .value("Mood", item.mood)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan.opacity(0.5), .blue.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    LineMark(
                        x: .value("Month", item.monthStart, unit: .month),
                        y: .value("Mood", item.mood)
                    )
                    .foregroundStyle(Color.cyan)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                .frame(height: 250)
                .chartYScale(domain: 0.5...5.5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

// MARK: - Stats Header
struct StatsHeader: View {
    @ObservedObject var viewModel: MoodSelectionViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Average",
                    value: String(format: "%.1f", viewModel.overallAverageMood),
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(viewModel.streakDays)",
                    icon: "flame.fill"
                )
                
                StatCard(
                    title: "Entries",
                    value: "\(viewModel.totalEntries)",
                    icon: "list.bullet.rectangle"
                )
            }
            
            if let best = viewModel.bestDay {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Best day:")
                    Text(formatDate(best.date))
                    Text(String(format: "%.1f", best.mood))
                        .fontWeight(.bold)
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.1))
        )
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Start tracking your mood daily to see insights")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Helper Functions
private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

private func formatTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: date)
}
