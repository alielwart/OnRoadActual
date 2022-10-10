import MapKit
import SwiftUI
import CoreLocation

struct Home: View {
    
    //used to get directions list
    @State private var directions: [String] = []
    @State private var location: String = ""
    @StateObject private var viewModel = ContentViewModel()
    
    
    //can't see directions if there aren't any
    @State private var showDirections = false
    
    var body: some View {
        VStack{
            VStack {
                MapView(directions: $directions)
                TextField(
                    "Enter Destination",
                    text: $location
                )
                .onSubmit{
                    //this is what I dont get
                    
                    //need to figure out how to call this
                   getCoordinate(addressString: location, completionHandler: <#T##(CLLocationCoordinate2D, NSError?) -> Void#>)
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
            } .sheet(isPresented: $showDirections, content: {
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
        
        //hides back buttonsince using navigation link
        .navigationBarBackButtonHidden(true)
        
        
        
    }
    
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
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
func getCoordinate( addressString : String,
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
}
