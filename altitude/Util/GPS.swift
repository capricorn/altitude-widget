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
    
    init() {}
    
    func locationFuture(_ callback: @escaping (CLLocation)->Void) {
        //let loc = Future() { promise in
        //let manager = CLLocationManager()
        //let continuationDelegate = LocationFutureDelegate()
        callbackDelegate = LocationFutureDelegate()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.delegate = callbackDelegate
        
        //continuationDelegate.promise = promise
        callbackDelegate.callback = callback
        locationManager.startUpdatingLocation()
            
            //manager.stopUpdatingLocation()
        //}
        
        // TODO: 'Just' for a one-shot publisher?
        //return loc
        //return Just(loc)
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
