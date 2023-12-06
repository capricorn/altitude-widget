//
//  LocationDelegate.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/25/23.
//

import Foundation
import Combine
import CoreLocation

class LocationFutureDelegate: NSObject, CLLocationManagerDelegate {
    var callback: ((Result<CLLocation, GPS.AuthorizationError>) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            manager.stopUpdatingLocation()
            self.callback?(.success(lastLocation))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
        self.callback?(.failure(GPS.AuthorizationError()))
    }
}
