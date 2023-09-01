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

// One-time delegate -- pass each time when location updates start -- stop immediately after.
class LocationContinuationDelegate: NSObject, CLLocationManagerDelegate {
    /*
    let continuation: CheckedContinuation<CLLocation, Never>
    
    init(_ continuation: CheckedContinuation<CLLocation, Never>) {
        self.continuation = continuation
    }
    */
    var continuation: CheckedContinuation<CLLocation, Never>!
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            continuation.resume(returning: lastLocation)
        }
    }
}

extension CLLocationManager {
    // TODO: Attempt, async unit test..? (Need to mock..)
    func getLocation(delegate: LocationContinuationDelegate) async -> CLLocation {
        let location = await withCheckedContinuation { continuation in
            // TODO: Figure out reference
            delegate.continuation = continuation
            self.delegate = delegate
            //self.delegate = LocationContinuationDelegate(continuation)
            self.startUpdatingLocation()
        }
        
        self.stopUpdatingLocation()
        self.delegate = nil
        
        return location
    }
}
