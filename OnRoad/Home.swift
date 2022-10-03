//
//  Home.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct Home: View {
    @State var showSettingsView: Bool = false
    var body: some View {
        VStack{
            Text("Enter your Location")
                .foregroundColor(Color.red)
                .multilineTextAlignment(.center)
                .padding(.top, 0.0)
                
        
            NavigationLink("Settings", destination: Settings())
                .padding(5.0)
        }
        .navigationBarBackButtonHidden(true)
        
        

    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
