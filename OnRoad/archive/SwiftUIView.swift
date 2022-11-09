////
////  SwiftUIView.swift
////  OnRoad
////
////  Created by Ali Elwart on 10/11/22.
////
//
//import SwiftUI
//import MapKit
//
//struct SwiftUIView: View {
//    @State private var directions: [String] = []
//    @State public var location: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
//    @State public var personalloc: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
//    @State private var showDirections = false
//    
//    
//    var body: some View {
//        VStack{
//            MapView(directions: $directions)
//            
//            Button(action: {
//                self.showDirections.toggle()
//            }, label: {
//                Text("show directions")
//            })
//            .disabled(directions.isEmpty)
//            .padding()
//            .sheet(isPresented: $showDirections, content: {
//                VStack{
//                    Text("directions")
//                        .font(.largeTitle)
//                        .bold()
//                        .padding()
//                    
//                    Divider().background(Color.blue)
//                    
//                    List {
//                        ForEach(0..<self.directions.count, id: \.self) {i in Text(self.directions[i])
//                                .padding()
//                        }
//                    }
//                }
//            })
//        }
//    }
//}
//
//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
//
//struct MapView: UIViewRepresentable {
//    typealias UIViewType = MKMapView
//    
//    @Binding var directions: [String]
//
//    
//    
//    
//    /*init(directions : [String], loc : MKPlacemark) {
//     self.directions = directions
//     self.loc = loc
//     } */
//    
//    
//    func makeCoordinator() -> MapViewCoordinator {
//        return MapViewCoordinator()
//    }
//    
//    func makeUIView(context: Context) -> MKMapView {
//        
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//        
//        
//        //let personalloc = home.personalloc
//        
//        //defines what is show when open
//        //TODO: get user location -> set region to this
//        //let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74), span:MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
//        
//        //mapView.setRegion(region, animated: true)
//        
//        //Ann Arbor for static
//        //TODO: change to current location
//        
//        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74))
//        //TODO: get user entry from text entry, will need to find a way to convert location to lat & long
//        
//        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude:  41.88, longitude: -87.62))
//        print(p1,p2)
//        
//        //just getting requirments for destination calcualtion
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: p1)
//        request.destination = MKMapItem(placemark: p2)
//        request.transportType = .automobile
//        
//        let directions = MKDirections(request: request)
//        
//        
//        //if possible to get route gets route, it not returns
//        directions.calculate { response, error in
//            guard let unwrappedResponse  = response else { return }
//            
//            for route in unwrappedResponse.routes {
//                mapView.addAnnotation(p1)
//                mapView.addAnnotation(p2)
//                mapView.addOverlay(route.polyline)
//                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
//                self.directions = route.steps.map{ $0.instructions}.filter { !$0.isEmpty }
//            }
//            
//        }
//        
//        
//        return mapView
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        
//    }
//    
//    //create line between locations
//    class MapViewCoordinator: NSObject, MKMapViewDelegate {
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = .purple
//            renderer.lineWidth = 5
//            return renderer
//        }
//    }
//}
