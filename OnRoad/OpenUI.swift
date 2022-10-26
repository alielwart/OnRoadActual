//
//  OpenUI.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI
import GameController
import Foundation
import CoreHaptics

struct OpenUI: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    
    //TODO: overall make prettier 
    var body: some View {
        VStack(alignment: .center, spacing: 200) {
            //TODO: change to OnRoad logo!
            if colorScheme == .light {
                Image("logo")
            }
            else {
                Image("logo-dark")
            }
//            Text("Naviagtion Assistant")
//                    .font(.title)
            VStack(alignment: .center, spacing: 50) {
                NavigationLink(destination: Home()) {
                    if #available(iOS 15.0, *) { //xcode required this for devices not on ios15
                        Text("Navigate")
                            .padding()
                            .frame(minWidth: 0, maxWidth: 300)
                            .foregroundColor(.white)
                            .background(.blue) //don't know what color yet
                            .cornerRadius(40)
                            .font(.title)
                    } else {
                        // Fallback on earlier versions
                        Text("Please update your mobile device to IOS15 to use OnRoad")
                    }
                }
                
                NavigationLink(destination: Settings()) {
                    if #available(iOS 15.0, *) { //xcode required this for devices not on ios15
                        Text("Settings")
                            .padding()
                            .frame(minWidth: 0, maxWidth: 300)
                            .foregroundColor(.white)
                            .background(.blue) //don't know what color yet
                            .cornerRadius(40)
                            .font(.title)
                    } else {
                        // Fallback on earlier versions
                        Text("Please update your mobile device to IOS15 to use OnRoad")
                    }
                }
                
                Button(action: {
                    
                    //code to test vibrating xbox
                    
                    //starts haptic engine
                    startHapticEngine();
                    
                    //play haptic pattern
                    playHaptics();
                    
                    
                }, label: {
                    Text("test vibration")
                })
                
           
                
            }
        }
    }
}

struct OpenUI_Previews: PreviewProvider {
    static var previews: some View {
        OpenUI().preferredColorScheme(.dark)
    }
}


private var engineMap = [GCHapticsLocality: CHHapticEngine]()

func startHapticEngine(){
    
    
    var controller = GCController.controllers()[0]
    
    guard let engine = controller.haptics?.createEngine(withLocality: .default) else {
        print("Failed to create engine.")
        return
    }
    
    engineMap[GCHapticsLocality.default] = engine

    do {
        try engine.start()
    } catch let error {
        fatalError("Engine Start Error: \(error)")
    }
    
    
    
}

func playHaptics(){
    do {
        
        let hapticPlayer = try createPattern()
        
        try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        
    } catch let error {
        print("Haptic Player Error: \(error) ")
    }
    
    
}

func createPattern() throws -> CHHapticPatternPlayer? {
    
    let continuousEvent = CHHapticEvent(eventType: .hapticContinuous, parameters: [
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        ], relativeTime: 0, duration: 1)
    
    let pattern = try CHHapticPattern(events : [continuousEvent], parameters: [])
    
    let tempEng = engineMap[GCHapticsLocality.default]
    
    return try tempEng!.makePlayer(with: pattern)
    
    
    
}


