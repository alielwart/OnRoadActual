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

    // Publicly accessible settings
    @EnvironmentObject var settings: SettingsObj
    
//    TODO: Implement the vIsToggled and vIntensity as variables in a settings class object in the main page
    
    var body: some View {
        NavigationView {
            
            Form {
                
                // TESTING VARIABLE
                Text("TESTING VARIABLE")
                Text("Intensity: ")
                Text("\(settings.vIntensity, specifier: "%.0F")")
                    .foregroundColor(settings.vIsToggled ? .blue : .gray)


                // Main Vibration Toggle
                Section(header: Text("Vibration")){
                    
                    //TODO: implement working vibration on off
                    Toggle(isOn: $settings.vIsToggled, label: {
                        Text("Vibration")
                    })
                }
                
                // More Vibration Settings
                Section{
                
                    // Text: Vibration Intensity
                    Text("Vibration Intensity: ").foregroundColor(settings.vIsToggled ? .black : .gray)
                    
                    // Slider
                    Slider(
                        value: $settings.vIntensity,
                        in: 0...10,
                        step: 1
                    ).padding(.horizontal, 20.0)
                        .accentColor(settings.vIsToggled ? .blue : .gray)
                
                    // Intensity Level
                    Text("\(settings.vIntensity, specifier: "%.0F")")
                        .foregroundColor(settings.vIsToggled ? .blue : .gray)

                    // Text: Vibration Frequency
                    Text("Vibration Frequency").foregroundColor(settings.vIsToggled ? .black : .gray)
                    
                    // Slider
                    Slider(
                        value: $settings.vFrequency,
                        in: 0...100,
                        step: 1
                    ).padding(.horizontal, 20.0)
                        .accentColor(settings.vIsToggled ? .blue : .gray)
                
                    // Frequency Level
                    Text("\(settings.vFrequency, specifier: "%.0F")")
                        .foregroundColor(settings.vIsToggled ? .blue : .gray)
                    
                    
                }.disabled(settings.vIsToggled == false)

                
                
            }.navigationTitle("Settings")
        }
        
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(SettingsObj())
    }
}
