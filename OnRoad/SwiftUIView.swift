//
//  navTest.swift
//  OnRoad
//
//  Created by Lilly Wu on 10/10/22.
//
import MapKit
import SwiftUI
import CoreLocation

struct navTest : View {
    @State private var location: String = " "
    
    var body : some View {
        VStack {
            Text("Hello")
            TextField("Enter Coords",
                      text: $location)
                .onSubmit {
                    printCoords(address: location)
                }

        }
    }
}

struct navTest_Previews: PreviewProvider {
    static var previews: some View {
        navTest()
    }
}

struct getcords {
    static var longnew = 43.28
    //TO DO:
    static var latnat = 45.21
    //need to connect this back to main nav page + get directions
    func printCoords(address : String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if let placemark = placemarks?.first {
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                getcords.latnat = coordinates.latitude
                getcords.longnew = coordinates.longitude
                print(getcords.latnat)
                print(getcords.longnew)
            }
        })
        //TO DO:
        //need to find a way to handle null/error values
        //probably with an if statement
        //EX:
        
        // if ((error) != nil) for error
        // if placemark == nil --> do something
    }
}
