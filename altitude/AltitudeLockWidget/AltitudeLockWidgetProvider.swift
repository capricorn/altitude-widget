//
//  AltitudeLockWidgetProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit

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
        queue.async(group: group) {
            //group.enter()
            
            var currentDate = currentDate
            
            // TODO: Replace w/ equivalent user defaults calls
            
            if let currentAltitude = defaults.currentAltitude, (currentDate - currentAltitude.date).min < 1 {
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
                //group.leave()
                return
            } else {
                group.enter()
                gps.locationFuture { location in
                    if let recentAltitude = defaults.currentAltitude {
                        defaults.lastAltitude = recentAltitude
                    }
                    
                    let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
                    let entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
                    let prevEntry = defaults.lastAltitude
                    
                    defaults.currentAltitude = entry
                    
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
                
                group.wait()
            }
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        updateTimeline(completion: completion)
    }
}
