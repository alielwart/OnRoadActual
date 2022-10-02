//
//  mapView.swift
//  OnRoad
//
//  Created by Ali Elwart on 10/2/22.
//

import SwiftUI
import MapKit

struct mapView: View {
    @State private var region = MKCoordinateRegion(
           center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
           span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
       )
    var body: some View {
        Map(coordinateRegion: $region)
    }
}

struct mapView_Previews: PreviewProvider {
    static var previews: some View {
        mapView()
    }
}
