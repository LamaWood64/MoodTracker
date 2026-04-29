//
//  DailyTrendChart.swift
//  MoodTracker
//
//  Created by Anastasia on 28.04.26.
//

import SwiftUI
import Charts

struct DailyTrendChart: View {
    let entries: [(time: Date, mood: Int)]
    let date: Date
    
    var body: some View {
        if entries.isEmpty {
            EmptyStateView(message: "No entries for this day")
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Mood Changes During Day")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(formatTimeRange())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Chart(entries, id: \.time) { entry in
                    LineMark(
                        x: .value("Time", entry.time, unit: .hour),
                        y: .value("Mood", entry.mood)
                    )
                    .foregroundStyle(.cyan)
                    .interpolationMethod(.catmullRom)
                    
                    PointMark(
                        x: .value("Time", entry.time, unit: .hour),
                        y: .value("Mood", entry.mood)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(100)
                }
                .frame(height: 200)
                .chartYScale(domain: 0.5...5.5)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.white.opacity(0.3))
                        AxisValueLabel(format: .dateTime.hour().minute())
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    private func formatTimeRange() -> String {
        guard let first = entries.first?.time,
              let last = entries.last?.time else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
}
