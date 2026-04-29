//
//  HistoryView.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.

import SwiftUI

struct HistoryView: View {
    
    @ObservedObject var viewModel: MoodSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.blue.opacity(0.5), .purple.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("All Entries")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        let groupedByDay = Dictionary(grouping: viewModel.moodEntries) { entry in
                            Calendar.current.startOfDay(for: entry.date)
                        }.sorted { $0.key > $1.key }
                        
                        if groupedByDay.isEmpty {
                            EmptyStateView(message: "No mood entries yet")
                        } else {
                            ForEach(groupedByDay, id: \.key) { date, entries in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(formatDate(date))
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if let average = viewModel.averageMood(for: date) {
                                            Text("Avg: \(String(format: "%.1f", average))")
                                                .font(.caption)
                                                .foregroundColor(.cyan)
                                        }
                                        
                                        Text("(\(entries.count))")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(entries.sorted(by: { $0.date < $1.date })) { entry in
                                        HStack {
                                            Image(systemName: "clock")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.6))
                                            
                                            Text(formatTime(entry.date))
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.7))
                                            
                                            Spacer()
                                            
                                            Circle()
                                                .fill(moodColor(entry.value))
                                                .frame(width: 8, height: 8)
                                            
                                            Text("Mood: \(entry.value)")
                                                .font(.body)
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.ultraThinMaterial)
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
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
    
    private func moodColor(_ value: Int) -> Color {
        switch value {
        case 1: return .purple
        case 2: return .blue
        case 3: return .cyan
        case 4: return .green
        default: return .yellow
        }
    }
}
