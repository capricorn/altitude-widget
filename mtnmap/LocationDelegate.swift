//
//  LocationDelegate.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/25/23.
//

import Foundation
import Combine
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    lazy var locationPublisher = locationSubject.eraseToAnyPublisher()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // TODO -- locations.last is the most-recent location
        // Could publish and make available as a stream
        print("Received locations: \(locations)")
        if let lastLocation = locations.last {
            locationSubject.send(lastLocation)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // TODO -- handle authorization status changes
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
}
