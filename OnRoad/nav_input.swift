//
//  nav_input.swift
//  OnRoad
//
//  Created by Lilly Wu on 12/4/22.
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

// Need to do:
// Text input

// Combines Swift UI and Storyboard
struct Maps: View {
    var body: some View {
        MapsViewWrapper()
    }
}

struct Maps_Previews: PreviewProvider {
    static var previews: some View {
        Maps()
    }
}

// Storyboard Wrapper
struct MapsViewWrapper : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MapsViewController {
        return MapsViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapsViewController, context: Context) {
        // nothing to do here
    }
}

// Init a map
class MapsViewController: UIViewController, AnnotationInteractionDelegate {
    
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    
    var beginAnnotation: PointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationMapView = NavigationMapView(frame: view.bounds)
        
        view.addSubview(navigationMapView)
        
        // Set annotation manager delegate
        navigationMapView.mapView.mapboxMap.onNext(event: .mapLoaded) {
            [weak self] _ in
            guard let self = self
            else {return}
            self.navigationMapView.pointAnnotationManager?.delegate = self
        }
        
        // How map displays the users location
        navigationMapView.userLocationStyle = .puck2D()
        
        // Switch viewport datasource to track `raw` location updates instead of `passive` mode.
        navigationMapView.navigationCamera.viewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        
        //To Do:
            //
    }
    
    func annotationManager(_ manager: MapboxMaps.AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        
        guard annotations.first?.id == beginAnnotation?.id,
            let routeResponse = routeResponse, let routeOptions = routeOptions
        else {
            return
        }
        
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions)
        
        navigationViewController.modalPresentationStyle = .fullScreen
        
        self.present(navigationViewController, animated: true, completion: nil)
    }
}


