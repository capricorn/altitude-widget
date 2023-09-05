//
//  AltitudeGraphProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit
import CoreLocation

@MainActor
class GPS {
    static let shared = GPS()
    
    var locationManager = CLLocationManager()
    var delegate: LocationContinuationDelegate!
    
    init() {}
    
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
    
    /*
    @MainActor
    var location: CLLocation {
        get async {
            let result = await withCheckedContinuation { continuation in
                assert(Thread.isMainThread)
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                delegate = LocationContinuationDelegate()
                
                // has to be that the delegates are somehow lost..
                
                delegate.continuation = continuation
                locationManager.delegate = delegate
                
                locationManager.startUpdatingLocation()
            }
            
            locationManager.stopUpdatingLocation()
            return result
            
            /*
            let task = Task { @MainActor in
                assert(Thread.isMainThread)
                print("Location authorization status: \(locationManager.authorizationStatus)")
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                delegate = LocationContinuationDelegate()
                // Suspect this await is the problem.. another task perhaps runs in the meantime (and so the delegate is lost..)
                // Although presumably the last set delegate would work..?
                let location = await withCheckedContinuation { continuation in
                    assert(Thread.isMainThread)
                    // TODO: Figure out reference
                    /*
                    delegate.continuation = continuation
                    locationManager.delegate = delegate
                     */
                    locationManager.startUpdatingLocation()
                    // Verify that the continuation works at all
                    continuation.resume(with: .success(CLLocation(latitude: 10.0, longitude: 10.0)))
                }
                
                locationManager.stopUpdatingLocation()
                return location
            }
            
            let location = try! await task.result.get()
            return location
             */
            /*
            await MainActor.run(resultType: CLLocation.self) { () -> CLLocation in
                print("Location authorization status: \(locationManager.authorizationStatus)")
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                delegate = LocationContinuationDelegate()
                let location = await withCheckedContinuation { continuation in
                    // TODO: Figure out reference
                    delegate.continuation = continuation
                    locationManager.delegate = delegate
                    locationManager.startUpdatingLocation()
                }
                
                locationManager.stopUpdatingLocation()
                return location
            }
            */
        }
    }
    */
}

struct AltitudeGraphProvider: TimelineProvider {
    private class EntryStack {
        let stackSize: Int
        var entries: [AltitudeStepEntry.Altitude] = []
        
        init(stackSize: Int) {
            self.stackSize = stackSize
        }
        
        func push(_ altitude: AltitudeStepEntry.Altitude) {
            if entries.count == stackSize {
                entries.remove(at: 0)
            }
            
            self.entries.append(altitude)
        }
    }
    
    typealias Entry = AltitudeStepEntry
    
    // TODO: Does this work in practice?
    private let entryStack = EntryStack(stackSize: 5)
    private let locationManager = CLLocationManager()
    private let locationDelegate = LocationDelegate()
    //private var locationDelegate = LocationContinuationDelegate()
    
    private var timelineEntries: Timeline<AltitudeStepEntry> {
        Timeline(entries: [ AltitudeStepEntry(altitudes: entryStack.entries) ], policy: .atEnd)
    }
    
    init() {
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Not ideal to poll location all of the time
        locationManager.startUpdatingLocation()
    }
    
    func placeholder(in context: Context) -> AltitudeStepEntry {
        let altitudes = (0..<5).map { _ in AltitudeStepEntry.Altitude(value: Int.random(in: 10...100), time: Date()) }
        return AltitudeStepEntry(altitudes: altitudes)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AltitudeStepEntry) -> Void) {
        let entry = AltitudeStepEntry(altitudes: entryStack.entries)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AltitudeStepEntry>) -> Void) {
        // TODO: Is this the correct way to avoid dupes across widgets..?
        // (Seems they share the same provider across all families..?)
        guard context.family == .accessoryRectangular else {
            completion(timelineEntries)
            return
        }
        
        Task { @MainActor in
            let manager = CLLocationManager()
            let delegate = LocationContinuationDelegate()
            let endDate = Date().addingTimeInterval(15*60)
            
            manager.delegate = delegate
            
            let location = await withCheckedContinuation { continuation in
                delegate.continuation = continuation
                manager.startUpdatingLocation()
            }
            
            manager.stopUpdatingLocation()
            
            let altitude = AltitudeStepEntry.Altitude(value: Int(location.altitude), time: Date())
            
            //let altitude = AltitudeStepEntry.Altitude(value: Int.random(in: 10...100), time: Date())
            
            entryStack.push(altitude)
            
            let entry = AltitudeStepEntry(altitudes: entryStack.entries, date: endDate)
            
            completion(Timeline(entries: [entry], policy: .atEnd))

        }
        /*
        let manager = CLLocationManager()
        let delegate = LocationContinuationDelegate()
        
        //delegate.continuation = ...
        
        manager.delegate = delegate
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Problem with above approach: need to capture vars or they will instantly deallocate
        manager.startUpdatingLocation()
         */
        /*
        DispatchQueue.main.async {
            // One option: the above completion to the
        }
         */
        
        
        //completion(Timeline(entries: [AltitudeStepEntry(altitudes: [.init(value: 10, time: Date())])], policy: .atEnd))
        
        // Perform gps reading, use completion callback here
        /*
        Task { @MainActor in
            let endDate = Date().addingTimeInterval(60)
            //let locationDelegate = LocationContinuationDelegate()
            let gps = GPS()
            let manager = CLLocationManager()
            gps.locationManager = manager
            //assert(gps.locationManager.allowsBackgroundLocationUpdates)
            assert(Thread.isMainThread)
            let location = await gps.location //await locationManager.getLocation(delegate: locationDelegate)
            let altitude = AltitudeStepEntry.Altitude(value: Int(location.altitude), time: Date())
            
            //let altitude = AltitudeStepEntry.Altitude(value: Int.random(in: 10...100), time: Date())
            
            entryStack.push(altitude)
            
            let entry = AltitudeStepEntry(altitudes: entryStack.entries, date: endDate)
            
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
         */
    }
}
