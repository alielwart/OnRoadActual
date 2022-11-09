////
////  maps.swift
////  OnRoad
////
////  Created by Ali Elwart on 11/7/22.
////
//
//import SwiftUI
//import MapboxMaps
//import MapboxDirections
//import MapboxCoreNavigation
//import MapboxNavigation
//import CoreLocation
//
//
//struct maps: View {
//    var body: some View {
//        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//        MapViewWrapper()
//    }
//}
//
//struct maps_Previews: PreviewProvider {
//    static var previews: some View {
//        maps()
//    }
//}
//
//struct MapViewWrapper : UIViewControllerRepresentable {
//  
//   func makeUIViewController(context: Context) -> ViewController {
//       return ViewController()
//   }
//  
//   func updateUIViewController(_ uiViewController: ViewController, context: Context) {
//      
//   }
//}
//
//class ViewController: UIViewController {
//   internal var mapViewer: MapView!
//   override public func viewDidLoad() {
//       super.viewDidLoad()
//       let origin = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.9131752, longitude: -77.0324047), name: "Mapbox")
//       let destination = Waypoint(coordinate: CLLocationCoordinate2D(latitude: 38.8977, longitude: -77.0365), name: "White House")
//        
//       // Set options
//       let routeOptions = NavigationRouteOptions(waypoints: [origin, destination])
//        
//       // Request a route using MapboxDirections.swift
//       Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
//       switch result {
//       case .failure(let error):
//       print(error.localizedDescription)
//       case .success(let response):
//       guard let self = self else { return }
//       // Pass the first generated route to the the NavigationViewController
//       let viewController = NavigationViewController(for: response, routeIndex: 0, routeOptions: routeOptions)
//           print(routeOptions)
//           print("HETR")
//       viewController.modalPresentationStyle = .fullScreen
//       self.present(viewController, animated: true, completion: nil)
//        }
//   }
//}
//}
