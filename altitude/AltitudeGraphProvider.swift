//
//  AltitudeGraphProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit
import CoreLocation

struct AltitudeGraphProvider: TimelineProvider {
    private class EntryStack {
        let stackSize: Int
        var entries: [Altitude] = []
        
        init(stackSize: Int) {
            self.stackSize = stackSize
        }
        
        func push(_ altitude: Altitude) {
            if entries.count == stackSize {
                entries.remove(at: 0)
            }
            
            self.entries.append(altitude)
        }
    }
    
    typealias Entry = Altitude
    
    // TODO: Does this work in practice?
    private let entryStack = EntryStack(stackSize: 5)
    private let locationManager = CLLocationManager()
    //private var locationDelegate = LocationContinuationDelegate()
    
    func placeholder(in context: Context) -> Altitude {
        return Altitude(location: 10, timestamp: 10)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Altitude) -> Void) {
        let altitude = Altitude(location: 50, timestamp: Int(Date().timeIntervalSince1970))
        completion(altitude)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Altitude>) -> Void) {
        let endDate = Date().addingTimeInterval(15*60)
        
        // Perform gps reading, use completion callback here
        Task {
            let locationDelegate = LocationContinuationDelegate()
            let location = await locationManager.getLocation(delegate: locationDelegate)
            let entry = Altitude(location: Int(location.altitude), timestamp: Int(Date().timeIntervalSince1970))
            entryStack.push(entry)
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }
}
