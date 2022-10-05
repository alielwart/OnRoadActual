//
//  OpenUI.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct OpenUI: View {
    //TODO: overall make prettier 
    var body: some View {
        VStack(alignment: .center) {
            //TODO: change to OnRoad logo!
            Image("logo")
            Text("Naviagtion Assistant")
                    .font(.title)
            NavigationLink("Navigate", destination: Home())

        }
    }
}

struct OpenUI_Previews: PreviewProvider {
    static var previews: some View {
        OpenUI()
    }
}
