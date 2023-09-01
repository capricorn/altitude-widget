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
        let endDate = Date().addingTimeInterval(15*60)
        
        // Perform gps reading, use completion callback here
        Task {
            let locationDelegate = LocationContinuationDelegate()
            let location = await locationManager.getLocation(delegate: locationDelegate)
            
            let altitude = AltitudeStepEntry.Altitude(value: Int(location.altitude), time: Date())
            entryStack.push(altitude)
            
            let entry = AltitudeStepEntry(altitudes: entryStack.entries, date: endDate)
            
            completion(Timeline(entries: [entry], policy: .atEnd))
        }
    }
}
