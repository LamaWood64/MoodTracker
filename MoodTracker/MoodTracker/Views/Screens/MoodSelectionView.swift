//
//  MoodSelectionView.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.
//

import SwiftUI

struct MoodSelectionView: View {
    
    @StateObject private var viewModel = MoodSelectionViewModel()
    
    private var backgroundGradient: LinearGradient {
        let mood = viewModel.selectedMood ?? 3
        
        switch mood {
        case 1:
            return LinearGradient(
                colors: [.purple.opacity(0.8), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        case 2:
            return LinearGradient(
                colors: [.blue.opacity(0.7), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
        case 3:
            return LinearGradient(
                colors: [.cyan.opacity(0.6), .blue.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
        case 4:
            return LinearGradient(
                colors: [.mint.opacity(0.6), .green.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return LinearGradient(
                colors: [.yellow.opacity(0.6), .orange.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Text("How do you feel?")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: viewModel.selectedMood == mood
                            ) {
                                viewModel.selectMood(mood)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.saveMood()
                    }) {
                        Text("Save Mood")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                viewModel.selectedMood == nil
                                ? Color.gray.opacity(0.3)
                                : Color.blue.opacity(0.8)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }
                    .disabled(viewModel.selectedMood == nil)
                    .padding(.horizontal)
                    
                    HStack(spacing: 40) {
                        NavigationLink(
                            destination: HistoryView(viewModel: viewModel)
                        ) {
                            Label("History", systemImage: "list.bullet")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        NavigationLink(
                            destination: AnalyticsView(viewModel: viewModel)
                        ) {
                            Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    MoodSelectionView()
}
