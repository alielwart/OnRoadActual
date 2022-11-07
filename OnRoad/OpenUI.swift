//
//  OpenUI.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct OpenUI: View {
    
    // Store environment's color scheme
    @Environment(\.colorScheme) var colorScheme
    
    // Access the environment object created in OnRoadApp.swift
    @EnvironmentObject var settings: SettingsObj

    // ~~~~~~~ OpenUI View Body ~~~~~~~~
    var body: some View {
        VStack(alignment: .center, spacing: 200) {
            
            // Set Logo based on color scheme
            if colorScheme == .light {
                Image("logo")
            }
            else {
                Image("logo-dark")
            }

            VStack(alignment: .center, spacing: 50) {
                
                // NAVIGATE (HOME) BUTTON
                NavigationLink(destination: Home()) {
                    if #available(iOS 15.0, *) { //xcode required this for devices not on ios15
                        Text("Navigate")
                            .padding()
                            .frame(minWidth: 0, maxWidth: 300)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(40)
                            .font(.title)
                    } else {
                        // Fallback on earlier versions
                        Text("Please update your mobile device to IOS15 to use OnRoad")
                    }
                }
                
                // SETTINGS BUTTON
                NavigationLink(destination: Settings()) {
                    if #available(iOS 15.0, *) { //xcode required this for devices not on ios15
                        Text("Settings")
                            .padding()
                            .frame(minWidth: 0, maxWidth: 300)
                            .foregroundColor(.white)
                            .background(.blue)
                            .cornerRadius(40)
                            .font(.title)
                    } else {
                        // Fallback on earlier versions
                        Text("Please update your mobile device to IOS15 to use OnRoad")
                    }
                    
                } // Settings
            } // VStack
        } // VStack
    } // body
} // openUI

struct OpenUI_Previews: PreviewProvider {
    static var previews: some View {
        OpenUI().preferredColorScheme(.dark)
    }
}
