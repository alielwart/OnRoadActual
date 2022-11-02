import MapKit
import SwiftUI
import AudioToolbox
import AVFoundation


struct Home: View {
    
    //used to get directions list
    @State private var directions: [String] = []
    @State public var address: String
    @State public var location: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
    @StateObject private var viewModel = ContentViewModel()
    @State var count: Int = 0
    
    @State var p3: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74)
    @State var p4: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.28, longitude: -80.74)
    
    
    //can't see directions if there aren't any
    @State private var showDirections = false
    
    var body: some View {
        let convew = ContentViewModel()
        //let map = MapView(directions: $directions, loc: $location)
        VStack{
            VStack {
                MapView(directions: $directions)
                
                //                Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                //                    .ignoresSafeArea()
                //                    .accentColor(Color(.systemPink))
                //                    .onAppear{
                //                        viewModel.checkIfLocIsOn()
                //                    }
                
                //show directions button (probably won't be relevent when we get turn by turn)
                Button(action: {
                    self.showDirections.toggle()
                }, label: {
                    Text("show directions")
                })
                .disabled(directions.isEmpty)
                .padding()
                }.sheet(isPresented: $showDirections, content: {
                VStack{
                    Text("directions")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    Divider().background(Color.blue)
                    
                    List {
                        ForEach(0..<self.directions.count, id: \.self) {i in Text(self.directions[i])
                                .padding()
                        }
                    }
                }
            })
//            VStack {
//                Button(action: {
//                    print("opened new map")
//                }, label: {
//                    Text("render map")}
//                )
//            }.sheet(isPresented: $showDirections, content: {
//                    VStack{
//                        MapViewSlider(directions: $directions, p1: MKPlacemark(coordinate: p3), p2: MKPlacemark(coordinate: p4))
//                    }
//                })
            
            Button(action: {
//                print(self.count)
                if self.count < self.directions.count {
                    print(self.directions[self.count])
                    if self.directions[self.count].contains("left") {
                        print("left vibrate")
                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                        AudioServicesPlayAlertSound(SystemSoundID(1075))
                    }
                    else if self.directions[self.count].contains("right") {
                        print("right vibrate")
                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                        AudioServicesPlayAlertSound(SystemSoundID(1109))
                    }
                    else if self.directions[self.count].contains("Continue") {
                        print("continue vibrate")
                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
                        AudioServicesPlayAlertSound(SystemSoundID(1110))
                    }
                    self.count = self.count + 1
                }
            }, label: {
                Text("Next Direction")
            })
            
            //TODO: move to icon in top corner?
            //settings button
            NavigationLink("Settings", destination: Settings())
                .padding(5.0)
            
        }
        
        //hides back buttonsince using navigation link
//        .navigationBarBackButtonHidden(true)
        
        
        
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
struct MapViewSlider: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @Binding var directions: [String]
    
    @State var p1: MKPlacemark
    @State var p2: MKPlacemark
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        
        //defines what is show when open
        //TODO: get user location -> set region to this
        //let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74), span:MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        
        //mapView.setRegion(region, animated: true)
        
        //Ann Arbor for static
        //TODO: change to current location
        self.p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74))
        
        //TODO: get user entry from text entry, will need to find a way to convert location to lat & long
        self.p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 41.88, longitude: -87.62))
        
        //just getting requirments for destination calcualtion
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        
        //if possible to get route gets route, it not returns
        directions.calculate { response, error in
            guard let unwrappedResponse  = response else { return }
            
            for route in unwrappedResponse.routes {
                mapView.addAnnotation(p1)
                mapView.addAnnotation(p2)
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                self.directions = route.steps.map{ $0.instructions}.filter { !$0.isEmpty }
            }
            
        }
        
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    //create line between locations
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .purple
            renderer.lineWidth = 5
            return renderer
        }
    }
}
struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @Binding var directions: [String]
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        
        //defines what is show when open
        //TODO: get user location -> set region to this
        //let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74), span:MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        
        //mapView.setRegion(region, animated: true)
        
        //Ann Arbor for static
        //TODO: change to current location
        let p1 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74))
        
        //TODO: get user entry from text entry, will need to find a way to convert location to lat & long
        let p2 = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 41.88, longitude: -87.62))
        
        //just getting requirments for destination calcualtion
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: p1)
        request.destination = MKMapItem(placemark: p2)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        
        //if possible to get route gets route, it not returns
        directions.calculate { response, error in
            guard let unwrappedResponse  = response else { return }
            
            for route in unwrappedResponse.routes {
                mapView.addAnnotation(p1)
                mapView.addAnnotation(p2)
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                self.directions = route.steps.map{ $0.instructions}.filter { !$0.isEmpty }
            }
            
        }
        
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    //create line between locations
    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .purple
            renderer.lineWidth = 5
            return renderer
        }
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.28, longitude: -83.74), span:MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25));
    
    
    func checkIfLocIsOn(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            
        } else {
            print("Location isnt on ")
        }
    }
    
    private func checkLocationAuth(){
        guard let locationManager = locationManager else {return}
        
        switch locationManager.authorizationStatus {
            
            //means needs to ask for permision
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            //when resticted for app
        case .restricted:
            print("Your location is restricted")
            //says no to sharing
        case .denied:
            print("You said no :(")
            //
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
        @unknown default:
            break
        }
    }
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager){
            checkLocationAuth()
        }
    }
    
    
    //need this to return the location to be able to call in line 110
    // i tried changing the void to MKPlacemark but it didnt let me
    /*func getCoordinate( addressString : String,
     completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
     let geocoder = CLGeocoder()
     geocoder.geocodeAddressString(addressString) { (placemarks, error) in
     if error == nil {
     if let placemark = placemarks?[0] {
     let location = placemark.location!
     
     completionHandler(location.coordinate, nil)
     return
     }
     }
     
     completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
     }
     }*/
    
    
    func printCoords(address : String) -> MKPlacemark {
        let geocoder = CLGeocoder()
        //var directions: [String] = []
        var location = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if let placemark = placemarks?.first {
                
                let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                let lat = coordinates.latitude
                let long = coordinates.longitude
                
                location = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
            }
        })
        //MapView(directions: directions)
        print("1",location)
        return location
    }
    
    func convertCoords(address: String, completion: @escaping (_ location: CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks,
                  let location = placemarks.first?.location?.coordinate else {
                completion(nil)
                return
            }
            completion(location)
        }
    }

