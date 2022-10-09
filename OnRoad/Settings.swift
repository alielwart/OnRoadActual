//
//  Settings.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct Settings: View {
    @State private var speed = 50.0
    @State private var isEditing = false
    var body: some View {
        NavigationView {
            
            Form {
                Section(header: Text("Display")){
                    
                    //TODO: implement working nightmode
                    Toggle(isOn: .constant(true), label: {
                        Text("Night Mode")
                    })
                    
                }
                
                //TODO: add sections
                Section(header: Text("Accessibility")){
                    
//                    NavigationLink("Vibration Settings", destination: Vibration_Settings())
                    
                  
                            Section{
                                
                                //TODO: implement working vibration on off
                                Toggle(isOn: .constant(true), label: {
                                    Text("Vibration")
                                })
                            }
                    
                            Text("Change Vibration Intensity")
                            Slider(
                                value: $speed,
                                in: 0...100,
                                step: 5,
                                onEditingChanged: { editing in
                                    isEditing = editing
                                }
                            )
                            //TODO: change step to not have .000000000
                            .padding(.horizontal, 20.0)
                            Text("\(speed)")
                                .foregroundColor(isEditing ? .red : .blue)
                        }
                    
                    

                }
                .navigationTitle("Settings")
            }
        }
        
    }


struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
