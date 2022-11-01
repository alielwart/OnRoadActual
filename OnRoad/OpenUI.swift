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
                    
                    print(GCController.controllers())
                    
                    if(GCController.controllers() != []) {
                        
                        //starts haptic engine
                        startHapticEngine();

                        //play haptic pattern
                        playHaptics(pattern: 1);
                        
                    }
                    
                    
                    
                    
                }, label: {
                    Text("test vibration pattern 1")
                })
                
                Button(action: {
                    
                    //code to test vibrating xbox
                    
                    print(GCController.controllers())
                    
                    if(GCController.controllers() != []) {
                        
                        //starts haptic engine
                        startHapticEngine();

                        //play haptic pattern
                        playHaptics(pattern: 2);
                        
                    }
                    
                    
                    
                    
                }, label: {
                    Text("test vibration pattern 2")
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
    
    print(GCController.controllers)
    
    let controller = GCController.controllers()[0]
    
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

func playHaptics(pattern: Int){
    do {
        
        let hapticPlayer = try createPattern(pattern: pattern)
        
        try hapticPlayer?.start(atTime: CHHapticTimeImmediate)
        
    } catch let error {
        print("Haptic Player Error: \(error) ")
    }
    
    
}

func createPattern(pattern: Int) throws -> CHHapticPatternPlayer? {
    
    let continuousEvent_1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5 * Float(pattern)),
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5 * Float(pattern))
        ], relativeTime: 0, duration: 1)
    
    let transientEvent = CHHapticEvent(eventType: .hapticTransient, parameters: [
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
    ], relativeTime: 0, duration: 0.5)
    
    let continuousEvent_2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5),
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        ], relativeTime: 0, duration: 1)
    
    var hapticPattern = try CHHapticPattern(events : [continuousEvent_2], parameters: [])
    
    if(pattern == 2) {
        
        print(pattern)
        
        hapticPattern = try CHHapticPattern(events : [continuousEvent_1, transientEvent, continuousEvent_2,  continuousEvent_1], parameters: [])
        
    }
    
    let tempEng = engineMap[GCHapticsLocality.default]
    
    return try tempEng!.makePlayer(with: hapticPattern)
    
    
    
}


