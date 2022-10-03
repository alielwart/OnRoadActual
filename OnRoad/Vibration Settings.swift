//
//  Vibration Settings.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/3/22.
//

import SwiftUI

struct Vibration_Settings: View {
    @State private var speed = 50.0
    @State private var isEditing = false
    var body: some View {
        Text("Change Vibration Intensity")
        Slider(
                    value: $speed,
                    in: 0...100,
                    step: 5,
                    onEditingChanged: { editing in
                        isEditing = editing
                    }
        )
            .padding(.horizontal, 20.0)
                Text("\(speed)")
                    .foregroundColor(isEditing ? .red : .blue)
    }
}

struct Vibration_Settings_Previews: PreviewProvider {
    static var previews: some View {
        Vibration_Settings()
    }
}
