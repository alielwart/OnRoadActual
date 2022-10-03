//
//  OpenUI.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct OpenUI: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("OnRoad")
                .font(.largeTitle)
                .foregroundColor(Color.blue)
            .padding(.top, 3.0)
            Text("Naviagtion Assitant")
                    .font(.title)
                .foregroundColor(Color(hue: 0.581, saturation: 0.137, brightness: 1.0))
            NavigationLink("Navigate", destination: Home())

        }
    }
}

struct OpenUI_Previews: PreviewProvider {
    static var previews: some View {
        OpenUI()
    }
}
