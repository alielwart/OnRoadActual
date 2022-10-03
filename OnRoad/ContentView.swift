//
//  ContentView.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            OpenUI()
           
        }
    }
                
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct showMap: View {
    var body: some View {
    Home()
    }
}
