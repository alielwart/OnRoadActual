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
    @State private var location: String = "619 East University Ave, Ann Arbor, Michigan 48104"
    
    var body : some View {
        VStack {
            TextField("Enter Coords", text: $location)
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

//TO DO:
//need to connect this back to main nav page + get directions
func printCoords(address : String) {
    let geocoder = CLGeocoder()

    geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
        if let placemark = placemarks?.first {
            let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
            let lat = coordinates.latitude
            let long = coordinates.longitude
            print(lat)
            print(long)
        }
    })
    //TO DO:
    //need to find a way to handle null/error values
    //probably with an if statement
    //EX:
    
    // if ((error) != nil) for error
    // if placemark == nil --> do something
}

