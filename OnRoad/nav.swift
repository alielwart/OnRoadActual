//
//  nav.swift
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


// Combines swiftui and storyboard
struct DirMaps: View {
    @EnvironmentObject var settings: SettingsObj

    var body: some View {
        DirViewWrapper().environmentObject(settings)
    }
}

struct DirMaps_Previews: PreviewProvider {
    static var previews: some View {
        DirMaps()
    }
}

// Swift UI + ViewController Wrapper
struct DirViewWrapper : UIViewControllerRepresentable {
    @EnvironmentObject var settings: SettingsObj

    func makeUIViewController(context: Context) -> DirViewController {
        return DirViewController()
    }
    
    func updateUIViewController(_ uiViewController: DirViewController, context: Context) {
        // nothing here
    }
}

// Initialize a map, annotations, router

class DirViewController: UIViewController, AnnotationInteractionDelegate {
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    @EnvironmentObject var settings: SettingsObj


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
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable.
        // It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        
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
            let routeResponse = routeResponse, let routeOptions = routeOptions
        else {
            return
        }
        let navigationService = MapboxNavigationService(routeResponse: routeResponse,
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
        let navigationViewController = NavigationViewController(for: routeResponse,
                                                                routeIndex: 0,
                                                                routeOptions: routeOptions,
                                                                navigationOptions: navigationOptions)
        //navigationViewController.modalPresentationStyle = .fullScreen
        
        present(navigationViewController, animated: true, completion: nil)
    }
}

class CustomVoiceController: MapboxSpeechSynthesizer {
    @EnvironmentObject var settings: SettingsObj

    // You will need audio files for as many or few cases as you'd like to handle
    
    override func speak(_ instruction: SpokenInstruction, during legProgress: RouteLegProgress, locale: Locale? = nil) {
        
        guard let soundForInstruction = audio(progress: legProgress)
        else {
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
    
    
    func audio(progress: RouteLegProgress) -> Data? {
        // Vibration is synced to last spoken instruction which is right before a maneuver
        // Only checks for left/right keywords for now
        var total_inst_count = progress.currentStepProgress.step.instructionsSpokenAlongStep!.count
        if (progress.currentStepProgress.remainingSpokenInstructions?.count == 1
            && (progress.currentStepProgress.step.instructionsSpokenAlongStep![total_inst_count - 1].text.contains("left")
                || progress.currentStepProgress.step.instructionsSpokenAlongStep![total_inst_count - 1].text.contains("right")))
            {
                if(GCController.controllers() != []) {
    
                    //starts haptic engine
                    startHapticEngine();
    
                    let intensity = 2
    
                    let pattern = 2
    
                    //play haptic pattern
                    playHaptics(intensity: intensity, pattern: pattern)
    
                }
                return nil
        }
        return nil
    }
}
