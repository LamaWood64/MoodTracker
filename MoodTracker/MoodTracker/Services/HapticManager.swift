//
//  HapticManager.swift
//  MoodTracker
//
//  Created by Anastasia on 27.04.26.

#if canImport(UIKit)
import UIKit
#endif

class HapticManager {
    
    static let shared = HapticManager()
    
    private init() {}
    
    func tap() {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
