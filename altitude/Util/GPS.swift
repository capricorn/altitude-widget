//
//  GPS.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import Foundation
import CoreLocation
import Combine

//@MainActor
class GPS {
    static let shared = GPS()
    
    var locationManager = CLLocationManager()
    var delegate: LocationContinuationDelegate!
    
    var callbackDelegate: LocationFutureDelegate!
    
    struct AuthorizationError: Error {}
    
    init() {}
    
    func locationFuture(_ callback: @escaping (Result<CLLocation, AuthorizationError>)->Void) {
        callbackDelegate = LocationFutureDelegate()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = callbackDelegate
        callbackDelegate.callback = callback
        
        locationManager.startUpdatingLocation()
    }
    
    var location: CLLocation {
        get async {
            let manager = CLLocationManager()
            let continuationDelegate = LocationContinuationDelegate()
            
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            manager.delegate = continuationDelegate
            
            let location = await withCheckedContinuation { continuation in
                continuationDelegate.continuation = continuation
                manager.startUpdatingLocation()
            }
            
            manager.stopUpdatingLocation()
            return location
        }
    }
}

extension CLLocation {
    /// Obtain the altitude as an abstract measurement.
    var mAltitude: Measurement<UnitLength> {
        return Measurement(value: self.altitude, unit: .meters)
    }
}
