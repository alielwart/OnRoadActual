//
//  Settings.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct Settings: View {
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
                Section(header: Text("Assecibility")){
                    
                    NavigationLink("Vibration Settings", destination: Vibration_Settings())
                }
                .navigationTitle("Settings")
            }
        }
        
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
