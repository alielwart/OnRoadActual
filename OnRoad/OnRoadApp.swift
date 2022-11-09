//
//  OnRoadApp.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

// SETTINGS: stored in observable object
class SettingsObj: ObservableObject {
    
    @Published var vIntensity : Int = 1
    @Published var vFrequency : Float = 50
    @Published var vIsToggled : Bool = true
    @Published var Pattern : Int = 2
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
