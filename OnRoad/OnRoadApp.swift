//
//  OnRoadApp.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

enum Pattern: String, CaseIterable, Identifiable {
    case hit, inflate
    var id : Self {self}
}

enum Intensity: String, CaseIterable, Identifiable {
    case half, full
    var id : Self {self}
}

// SETTINGS: stored in observable object
class SettingsObj: ObservableObject {
    

    
    @Published var selectedIntensity : Intensity? = .half
    @Published var selectedPattern : Pattern = .hit
    @Published var vIntensity : Int = 1
    @Published var vFrequency : Float = 50
    @Published var vIsToggled : Bool = true
    @Published var Pattern : Int = 1
}

@main
struct OnRoadApp: App {
    
    // Create settings object in outermost parent view to be accessible in all views
    @StateObject var settings = SettingsObj()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings) // Make settings accessible in ContentView
        }
    }
}
