//
//  RetrieveDir.swift
//  OnRoad
//
//  Created by Lilly Wu on 11/8/22.
//

import SwiftUI
import MapboxMaps
import MapboxDirections
import MapboxCoreNavigation
import MapboxNavigation
import CoreLocation
import MapboxSpeech
import Foundation
import AVFoundation
import GameController

// NEED TO DO:
/*
 1. Replace the long press to get destination location with a text input
 2. Time the vibrations correctly with upcoming directions
        Need to do something to prevent for loop going to the end immediately
 3. Annotate/Clean Up
 */

//HELP IN MAPBOX_DOCS FILE

//combine swiftui and storyboard
struct DirMaps: View {
    var body: some View {
        DirViewWrapper()
    }
}

struct DirMaps_Previews: PreviewProvider {
    static var previews: some View {
        DirMaps()
    }
}

//wrapper
struct DirViewWrapper : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> DirViewController {
        return DirViewController()
    }
    
    func updateUIViewController(_ uiViewController: DirViewController, context: Context) {
        // nothing here
    }
}

// Initialize a map

class DirViewController: UIViewController, AnnotationInteractionDelegate {
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?

    var beginAnnotation: PointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationMapView = NavigationMapView(frame: view.bounds)

        view.addSubview(navigationMapView)

        // Set the annotation manager's delegate
        navigationMapView.mapView.mapboxMap.onNext(event: .mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.navigationMapView.pointAnnotationManager?.delegate = self
        }

        // Configure how map displays the user's location
        navigationMapView.userLocationStyle = .puck2D()
        
        // Switch viewport datasource to track `raw` location updates instead of `passive` mode.
        navigationMapView.navigationCamera.viewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        

        // Add a gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)
    }

    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }

        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: navigationMapView)

        let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)

        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            // Calculate the route from the user's location to the set destination
            calculateRoute(from: origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }

    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")

        
        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        
        routeOptions.includesSteps = true;
        

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                self?.presentNavigationWithCustomVoiceController(routeOptions: routeOptions, response: response)
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions

                // Draw the route on the map after creating it
                strongSelf.drawRoute(route: route)

                if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                    // Display callout view on destination annotation
                    annotation.textField = "Start navigation"
                    annotation.textColor = .init(UIColor.white)
                    annotation.textHaloColor = .init(UIColor.systemBlue)
                    annotation.textHaloWidth = 2
                    annotation.textAnchor = .top
                    annotation.textRadialOffset = 1.0
                    
                    strongSelf.beginAnnotation = annotation
                    strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                }
            }
        }
    }

    func drawRoute(route: Route) {

        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])

        // Show destination waypoint on the map
        navigationMapView.showWaypoints(on: route)
    }
    
    func presentNavigationWithCustomVoiceController(routeOptions: NavigationRouteOptions, response: RouteResponse) {
        // For demonstration purposes, simulate locations if the Simulate Navigation option is on.
        let navigationService = MapboxNavigationService(routeResponse: response,
                                                        routeIndex: 0,
                                                        routeOptions: routeOptions,
                                                        customRoutingProvider: NavigationSettings.shared.directions,
                                                        credentials: NavigationSettings.shared.directions.credentials,
                                                        simulating: .always)
        
        navigationService.simulationSpeedMultiplier = 2.0;
        // `MultiplexedSpeechSynthesizer` will provide "a backup" functionality to cover cases, which
        // our custom implementation cannot handle.
        let speechSynthesizer = MultiplexedSpeechSynthesizer([CustomVoiceController(), SystemSpeechSynthesizer()])
        
        // Create a `RouteVoiceController` type with a customized `SpeechSynthesizing` instance.
        // A route voice controller monitors turn-by-turn navigation events and triggers playing spoken instructions
        // as audio using the custom `speechSynthesizer` we created above.
        let routeVoiceController = RouteVoiceController(navigationService: navigationService,
                                                        speechSynthesizer: speechSynthesizer)
        // Remember to pass our RouteVoiceController` to `Navigation Options`!
        let navigationOptions = NavigationOptions(navigationService: navigationService,
                                                  voiceController: routeVoiceController)
        
        // Create `NavigationViewController` with the custom `NavigationOptions`.
        let navigationViewController = NavigationViewController(for: response,
                                                                routeIndex: 0,
                                                                routeOptions: routeOptions,
                                                                navigationOptions: navigationOptions)
        //navigationViewController.modalPresentationStyle = .fullScreen
        
        present(navigationViewController, animated: true, completion: nil)
    }

    // Present the navigation view controller when the annotation is selected
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard annotations.first?.id == beginAnnotation?.id,
            let routeResponse = routeResponse, let routeOptions = routeOptions else {
            return
        }
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions)
        
        navigationViewController.modalPresentationStyle = .fullScreen
        
        // ERROR: for loops run before api call? returns navigation controller...need to find a way to call this after api call returns OR have a separate function that only check whether progress has been made using notifications: https://stackoverflow.com/questions/57309240/mapbox-navigation-in-ios-with-in-my-mapview-controller
        
        // go to mapbox_docs section 2 for further directions on debugging

        
       /*  */
        self.present(navigationViewController, animated: true, completion: nil)
        print("moves")
        
        for leg in navigationViewController.route!.legs {
             if (leg == navigationViewController.navigationService.routeProgress.currentLeg) {
                 print("INSTRUCTION!!: ", navigationViewController.navigationService.routeProgress.upcomingStep!)
             }
         }
    }
    
}

class CustomVoiceController: MapboxSpeechSynthesizer {
    
    // You will need audio files for as many or few cases as you'd like to handle
    // This example just covers left and right. All other cases will fail the Custom Voice Controller and
    // force a backup System Speech to kick in
    //let turnLeft = NSDataAsset(name: "turnleft")!.data
    //let turnRight = NSDataAsset(name: "turnright")!.data
    
    override func speak(_ instruction: SpokenInstruction, during legProgress: RouteLegProgress, locale: Locale? = nil) {
        
        guard let soundForInstruction = audio(for: legProgress.currentStep) else {
            // When `MultiplexedSpeechSynthesizer` receives an error from one of it's Speech Synthesizers,
            // it requests the next on the list
            delegate?.speechSynthesizer(self,
                                        didSpeak: instruction,
                                        with: SpeechError.noData(instruction: instruction,
                                                                 options: SpeechOptions(text: instruction.text)))
            return
        }
        speak(instruction, data: soundForInstruction)
    }
    
    //the issue is that we are missing the first turn + we are syncing up to the voice (will need to be able to sync without it in case driver doesn't want it)
    //we will need to sync it up another with a navigation servce that is customized for both sound on and sound off
    //Also need to determine when vibrations will be sent, this is based on leg, step information, maneuver direction, and how close they are to the turn
    
    func audio(for step: RouteStep) -> Data? {
        @EnvironmentObject var settings: SettingsObj

        switch step.maneuverDirection {
        case .left:
//            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
//            AudioServicesPlayAlertSound(SystemSoundID(1075))
//            //let turnLeft = NSDataAsset(name: "turnleft")!.data
//            print("left turn")
            
            if(GCController.controllers() != []) {
                
                //starts haptic engine
                startHapticEngine();
                
                let intensity = settings.vIntensity
                
                let pattern = settings.Pattern

                //play haptic pattern
                playHaptics(intensity: intensity, pattern: pattern)
                
            }
            return nil
        case .right:
//            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {   }
//            AudioServicesPlayAlertSound(SystemSoundID(1075))
//           // let turnRight = NSDataAsset(name: "turnright")!.data
//            print("right turn")
            if(GCController.controllers() != []) {
                
                //starts haptic engine
                startHapticEngine();
                
                let intensity = settings.vIntensity
                
                let pattern = settings.Pattern

                //play haptic pattern
                playHaptics(intensity: intensity, pattern: pattern)
                
            }
            return nil
        default:
            return nil // this will force report that Custom View Controller is unable to handle this case
        }
    }
}
