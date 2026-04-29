//
//  MoodButton.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.
//

import SwiftUI

struct MoodButton: View {
    
    let mood: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var gradient: LinearGradient {
        switch mood {
        case 1:
            return LinearGradient(colors: [.purple.opacity(0.6), .blue.opacity(0.4)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(colors: [.blue.opacity(0.5), .cyan.opacity(0.4)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case 3:
            return LinearGradient(colors: [.cyan.opacity(0.4), .mint.opacity(0.4)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        case 4:
            return LinearGradient(colors: [.mint.opacity(0.5), .green.opacity(0.4)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.green.opacity(0.6), .yellow.opacity(0.4)],
                                  startPoint: .topLeading,
                                  endPoint: .bottomTrailing)
        }
    }
    
    var body: some View {
        Button(action: {
            action()
            HapticManager.shared.tap()
        }) {
            Text("\(mood)")
                .font(.system(size: 22, weight: .semibold))
                .frame(width: 64, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(gradient)
                        .opacity(isSelected ? 0.30 : 0.15)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(isSelected ? 0.25 : 0.12), lineWidth: 1)
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
        }
    }
}
