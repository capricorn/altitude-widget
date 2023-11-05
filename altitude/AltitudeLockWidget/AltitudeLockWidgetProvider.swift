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
    private let queue = DispatchQueue(label: "altitude-widget")
    private let gps: T
    private let group = DispatchGroup()
    
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
    
    func updateTimeline(completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        queue.async {
            group.wait()
            group.enter()
            
            let currentDate = Date()
            
            if let currentAltitude = cache.currentAltitude, (currentDate - currentAltitude.date).min < 5 {
                let entry = currentAltitude
                let prevEntry = cache.lastAltitude
                
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
                return
            } else {
                gps.locationFuture { location in
                    if let recentAltitude = cache.currentAltitude {
                        cache.lastAltitude = recentAltitude
                    }
                    
                    let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
                    let entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
                    let prevEntry = cache.lastAltitude
                    
                    cache.currentAltitude = entry
                    
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
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        updateTimeline(completion: completion)
    }
}
