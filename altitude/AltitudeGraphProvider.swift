//
//  AltitudeGraphProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit
import CoreLocation

class GPS {
    static let shared = GPS()
    
    private let locationManager = CLLocationManager()
    private var delegate: LocationContinuationDelegate!
    
    private init() {}
    
    var location: CLLocation {
        get async {
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
    }
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
    //private var locationDelegate = LocationContinuationDelegate()
    
    func placeholder(in context: Context) -> AltitudeStepEntry {
        let altitudes = (0..<5).map { _ in AltitudeStepEntry.Altitude(value: Int.random(in: 10...100), time: Date()) }
        return AltitudeStepEntry(altitudes: altitudes)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (AltitudeStepEntry) -> Void) {
        let entry = AltitudeStepEntry(altitudes: entryStack.entries)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AltitudeStepEntry>) -> Void) {
        
        // Perform gps reading, use completion callback here
        Task { @MainActor in
            let endDate = Date().addingTimeInterval(15*60)
            //let locationDelegate = LocationContinuationDelegate()
            let location = await GPS.shared.location //await locationManager.getLocation(delegate: locationDelegate)
            let altitude = AltitudeStepEntry.Altitude(value: Int(location.altitude), time: Date())
            
            //let altitude = AltitudeStepEntry.Altitude(value: Int.random(in: 10...100), time: Date())
            
            entryStack.push(altitude)
            
            let entry = AltitudeStepEntry(altitudes: entryStack.entries, date: endDate)
            
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }
}
