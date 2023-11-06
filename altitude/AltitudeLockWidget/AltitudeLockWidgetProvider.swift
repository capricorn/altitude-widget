//
//  AltitudeLockWidgetProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit
import CoreLocation

struct AltitudeLockWidgetProvider<T: GPS>: IntentTimelineProvider {
    class Cache {
        var lastRefresh: Date? = nil
        var currentAltitude: CompactAltitudeEntry? = nil
        var lastAltitude: CompactAltitudeEntry? = nil
    }
    
    let cache = Cache()
    private let gps: T
    
    let queue = AltitudeLockWidget.queue
    let group = AltitudeLockWidget.group
    
    init(gps: T = GPS()) {
        self.gps = gps
    }
    
    func placeholder(in context: Context) -> AltitudeEntryContainer {
        AltitudeEntryContainer(date: Date(), configuration: AltitudeIntent(), currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AltitudeEntryContainer) -> ()) {
        let entry = AltitudeEntryContainer(date: Date(), configuration: AltitudeIntent(), currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800))
        completion(entry)
    }
    
    func updateTimeline(currentDate: Date = Date(), defaults: UserDefaults = UserDefaults.Settings.defaults,  completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        queue.async {
            var currentDate = currentDate
            
            // TODO: Replace w/ equivalent user defaults calls
            
            if let currentAltitude = defaults.currentAltitude, (currentDate - currentAltitude.date).min < AltitudeLockWidget.cacheExpirationMin {
                let entry = currentAltitude
                let prevEntry = defaults.lastAltitude
                
                let container = AltitudeEntryContainer(
                    date: currentDate,
                    configuration: AltitudeIntent(),
                    currentEntry: entry,
                    prevEntry: prevEntry
                )
                
                let timeline = Timeline(
                    entries: [container],
                    policy: .after(currentDate + 15.min)
                )
                
                completion(timeline)
                return
            } else {
                // Problem: need to wait synchronously on this.
                DispatchQueue.global().async(group: group) {
                    gps.locationFuture { (result: Result<CLLocation, GPS.AuthorizationError>) in
                        var entry: CompactAltitudeEntry? = nil
                        var prevEntry: CompactAltitudeEntry? = nil
                        
                        // TODO: switch on result, handle failure.
                        switch result {
                        case .success(let location):
                            if let recentAltitude = defaults.currentAltitude {
                                defaults.lastAltitude = recentAltitude
                            }
                            
                            let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
                            let entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
                            let prevEntry = defaults.lastAltitude
                            
                            defaults.currentAltitude = entry
                            defaults.currentAccuracy = location.verticalAccuracy
                        case .failure(_):
                            defaults.currentAltitude = nil
                            defaults.lastAltitude = nil
                            defaults.currentAccuracy = nil
                        }
                                                
                        let container = AltitudeEntryContainer(
                            date: currentDate,
                            configuration: AltitudeIntent(),
                            currentEntry: entry,
                            prevEntry: prevEntry
                        )
                        
                        let timeline = Timeline(
                            entries: [container],
                            policy: .after(currentDate + 15.min)
                        )
                        
                        completion(timeline)
                        group.leave()
                    }
                }
                
                group.wait()
                return
            }
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        updateTimeline(completion: completion)
    }
}
