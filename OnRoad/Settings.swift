//
//  Settings.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct Settings: View {
    
    // Variables
    @State private var vIntensity : Float = 5
    @State private var vFrequency : Float = 50
    @State private var vIsToggled : Bool = false
    
    @Environment(\.colorScheme) var colorScheme

    
//    TODO: Implement the vIsToggled and vIntensity as variables in a settings class object in the main page
    
    var body: some View {
        NavigationView {
            
            Form {

                // Main Vibration Toggle
                Section(header: Text("Vibration")){
                    
                    //TODO: implement working vibration on off
                    Toggle(isOn: $vIsToggled, label: {
                        Text("Vibration")
                    })
                }
                
                // More Vibration Settings
                Section{
                
                    // Text: Vibration Intensity
//                    Text("Vibration Intensity").foregroundColor(vIsToggled ? .black : .gray)
                    
                    if colorScheme == .light {
                        Text("Vibration Intensity").foregroundColor(vIsToggled ? .black : .gray)
                    }
                    else {
                        Text("Vibration Intensity").foregroundColor(vIsToggled ? .white : .gray)
                    }
                    
                    // Slider
                    Slider(
                        value: $vIntensity,
                        in: 0...10,
                        step: 1
                    ).padding(.horizontal, 20.0)
                        .accentColor(vIsToggled ? .blue : .gray)
                
                    // Intensity Level
                    Text("\(vIntensity, specifier: "%.0F")")
                        .foregroundColor(vIsToggled ? .blue : .gray)

                    // Text: Vibration Frequency
//                    Text("Vibration Frequency").foregroundColor(vIsToggled ? .black : .gray)
                    if colorScheme == .light {
                        Text("Vibration Frequency").foregroundColor(vIsToggled ? .black : .gray)
                    }
                    else {
                        Text("Vibration Frequency").foregroundColor(vIsToggled ? .white : .gray)
                    }
                    
                    // Slider
                    Slider(
                        value: $vFrequency,
                        in: 0...100,
                        step: 1
                    ).padding(.horizontal, 20.0)
                        .accentColor(vIsToggled ? .blue : .gray)
                
                    // Frequency Level
                    Text("\(vFrequency, specifier: "%.0F")")
                        .foregroundColor(vIsToggled ? .blue : .gray)
                    
                    
                }.disabled(vIsToggled == false)

                
                
            }.navigationTitle("Settings")
        }
        
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
