import MapKit
import SwiftUI
import CoreLocation

struct Home: View {
    
    //used to get directions list
    @State private var directions: [String] = []
    @State public var address: String
    @State public var location: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
    @StateObject private var viewModel = ContentViewModel()
    
    //@State private var location: String = "619 East University Ave, Ann Arbor, Michigan 48104"
    @State private var dest_coords : CLLocationCoordinate2D?
        //access latitude and longitude here in struct vars
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    
    @State public var personalloc: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
    
    
    //can't see directions if there aren't any
    @State private var showDirections = false
    
    var body: some View {
        VStack{
            VStack{
                MapView(directions: $directions, loc: $location)
                SwiftUI.TextField(
                    "Enter Destination",
                    text: $address
                )
                
                .onSubmit {
                    convertCoords(address: address) { coordinates in
                        print(coordinates!)
                        self.dest_coords = coordinates
                        //update struct vars
                        self.latitude = dest_coords!.latitude
                        self.longitude = dest_coords!.longitude
                        location = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude))
                    }
                }
                Text("\(latitude)")
                Text("\(longitude)")
                personalloc = ContentViewModel.checkLocationAuth()
                //need to figure out how to call this
                //getCoordinate(addressString: location, completionHandler: <#T##(CLLocationCoordinate2D, NSError?) -> Void#>)
            }
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                .ignoresSafeArea()
                .accentColor(Color(.systemPink))
                .onAppear{
                    viewModel.checkIfLocIsOn()
                }
            
            //show directions button (probably won't be relevent when we get turn by turn)
            Button(action: {
                self.showDirections.toggle()
            }, label: {
                Text("show directions")
            })
            .disabled(directions.isEmpty)
            .padding()
            .sheet(isPresented: $showDirections, content: {
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
            
            //TODO: move to icon in top corner?
            //settings button
            NavigationLink("Settings", destination: Settings())
              .padding(5.0)
        }
        .navigationBarBackButtonHidden(true)
    }
        //hides back buttonsince using navigation link
        
        
        
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        //fix this
        Home(address: "")
    }
}

struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    @Binding var directions: [String]
    @Binding var loc: MKPlacemark

    
   
    
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
        
        let p1 = Home.personalloc
        
        //TODO: get user entry from text entry, will need to find a way to convert location to lat & long
        
        let p2 = Home.location
        
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
    var newLat = 42.48
    var newLong = 42.21
    
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
    
    func checkLocationAuth() -> MKPlacemark {
        guard let locationManager = locationManager else {return MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))}
        
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
            newLat = locationManager.location?.coordinate.latitude ?? 41.30
            newLong = (locationManager.location?.coordinate.longitude) ?? 41.30
        @unknown default:
            break
        }
        return MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: newLat, longitude: newLong))
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
