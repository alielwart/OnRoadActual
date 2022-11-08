//
//  Settings.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct Settings: View {
    
    // Publicly accessible settings
    @EnvironmentObject var settings: SettingsObj
    
    @Environment(\.colorScheme) var colorScheme
    
    enum Pattern: String, CaseIterable, Identifiable {
        case hit, inflate
        var id : Self {self}
    }
    
    @State private var selectedPattern: Pattern = .hit
    
    enum Intensity: String, CaseIterable, Identifiable {
        case half, full
        var id : Self {self}
    }
    
    @State private var selectedIntensity: Intensity? = .half
        
    var body: some View {
        NavigationView {
            
            Form {

                // TOGGLE VIBRATION: ON & OFF
                Section(header: Text("Vibration")){
                    
                    //TODO: implement working vibration on off
                    Toggle(isOn: $settings.vIsToggled, label: {
                        Text("Vibration")
                    })
                }
                
                // VIBRATION SETTINGS
                Section{
                
                    // ~~~~~~~~~~~~~ INTENSITY ~~~~~~~~~~~~~
                    // TEXT: Intensity
                    if colorScheme == .light {
                        Text("Vibration Intensity").foregroundColor(settings.vIsToggled ? .black : .gray)
                    }
                    else {
                        Text("Vibration Intensity").foregroundColor(settings.vIsToggled ? .white : .gray)
                    }

                    
                    // PICKER: Intensity (LOCAL VARIABLE)
                    Picker("Intensity", selection: $selectedIntensity) {
                        
                        Text("Half").tag(Intensity.half)
                        Text("Full").tag(Intensity.full)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    // PICKER: Intensity (GLOBAL VARIABLE)
                    Picker("Intensity", selection: settings.selectedIntensity) {

                        Text("Half").tag(Intensity.half)
                        Text("Full").tag(Intensity.full)

                    }.pickerStyle(SegmentedPickerStyle())


                    // PICKER: Intensity (GLOBAL VARIABLE)
//                    Picker("Select", selection: $selectedIntensity) {
//                        ForEach(Intensity.allCases) { item in
//                            Text(self.string(from: item)).tag(item)
//                        }
//                    }
                    
                    // TESTING: Trying to access enum values
//                    let enumName = String($selectedIntensity)
                    var enumName = "\($selectedIntensity)"
                    Text(enumName)
                    Text("Intensity: \($selectedIntensity)" as String)
                    let _ = print($selectedIntensity)
                    
                    // ~~~~~~~~~~~~~ PATTERN ~~~~~~~~~~~~~
                    // TEXT: Pattern
                    if colorScheme == .light {
                        Text("Vibration Pattern").foregroundColor(settings.vIsToggled ? .black : .gray)
                    }
                    else {
                        Text("Vibration Pattern").foregroundColor(settings.vIsToggled ? .white : .gray)
                    }
                   
                    // PICKER: Pattern
                    Picker("Pattern", selection: $selectedPattern) {
                        
                        Text("Hit").tag(Pattern.hit)
                        Text("Inflate").tag(Pattern.inflate)
                        
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    // ~~~~~~~~~~~~~ FREQUENCY ~~~~~~~~~~~~~
                    // TEXT: Frequency
                    if colorScheme == .light {
                        Text("Vibration Frequency").foregroundColor(settings.vIsToggled ? .black : .gray)
                    }
                    else {
                        Text("Vibration Frequency").foregroundColor(settings.vIsToggled ? .white : .gray)
                    }
                    
                    // SLIDER: Frequency
                    Slider(
                        value: $settings.vFrequency,
                        in: 0...100,
                        step: 1
                    ).padding(.horizontal, 20.0)
                        .accentColor(settings.vIsToggled ? .blue : .gray)
                
                    // VALUE: Frequency
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
