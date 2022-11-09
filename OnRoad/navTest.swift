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
    @State private var dest_coords : CLLocationCoordinate2D?
    //access latitude and longitude here in struct vars
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    
    //should find a better way to instantiate this
    var body : some View {

        VStack {
            //TO DO: Submit Button
            //text input can be submitted with return, but might want to add specific/recognizable submit button
            TextField("Enter Address", text: $location)
                .onSubmit {
                    self.convertCoords(address: location) { coordinates in
                        print(coordinates!)
                        self.dest_coords = coordinates
                        //update struct vars
                        self.latitude = dest_coords!.latitude
                        self.longitude = dest_coords!.longitude
                    }
                }
            Text("\(latitude)")
            Text("\(longitude)")
        }
        

    }
    func convertCoords(address: String, completion: @escaping (_ location: CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(location)
        }
    }
}

struct navTest_Previews: PreviewProvider {
    static var previews: some View {
        navTest()
    }
}

////TO DO:
////need to connect this back to main nav page + get directions
//    func convertCoords(address : String, completion: @escaping (CLLocationCoordinate2D?) -> ()) {
//    let geocoder = CLGeocoder()
//
//
//    geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
//        let placemark = placemarks?.first
//        let lat = placemark?.location?.coordinate.latitude
//        let long = placemark?.location?.coordinate.longitude
////        print(lat)
////        print(long)
//        completion(placemark?.location?.coordinate)
//    })
//
//    //TO DO:
//    //need to find a way to handle null/error values
//    //probably with an if statement
//    //EX:
//
//    // if ((error) != nil) for error
//    // if placemark == nil --> do something
//}

