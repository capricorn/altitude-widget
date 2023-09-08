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
}

struct AltitudeGraphProvider: IntentTimelineProvider {
    typealias Intent = AltitudeIntent
    typealias Entry = AltitudeStepEntry
    
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
    
    func getSnapshot(for configuration: AltitudeIntent, in context: Context, completion: @escaping (AltitudeStepEntry) -> Void) {
        let entry = AltitudeStepEntry(altitudes: entryStack.entries)
        completion(entry)
    }
    
    func getTimeline(for configuration: AltitudeIntent, in context: Context, completion: @escaping (Timeline<AltitudeStepEntry>) -> Void) {
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
    }
}
