//
//  GPS.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import Foundation
import CoreLocation
import Combine

class GPS {
    var locationManager = CLLocationManager()
    var callbackDelegate: LocationFutureDelegate!
    
    struct AuthorizationError: Error {}
    
    init() {}
    
    func location(_ callback: @escaping (Result<CLLocation, AuthorizationError>)->Void) {
        callbackDelegate = LocationFutureDelegate()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = callbackDelegate
        callbackDelegate.callback = callback
        
        locationManager.startUpdatingLocation()
    }
}

extension CLLocation {
    /// Obtain the altitude as an abstract measurement.
    var mAltitude: Measurement<UnitLength> {
        return Measurement(value: self.altitude, unit: .meters)
    }
}
