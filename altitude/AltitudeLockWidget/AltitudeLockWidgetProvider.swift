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
        //Task { @MainActor in
        // TODO: asyncAndWait?
        queue.async {
            //let group = DispatchGroup()
            group.wait()
            // TODO: Handle appropriately
            group.enter()
            
            let currentDate = Date()
            //let entry: CompactAltitudeEntry
            //let prevEntry: CompactAltitudeEntry?
            
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
            /*
             let lastAltitude = UserDefaults.Settings.defaults.lastAltitude
             let elapsedRefreshTime = currentDate - (cache.lastRefresh ?? currentDate)
             */
            
            //cache.lastRefresh = Date()
            
            // This (approximately) handles multiple widget calls one after the other
            // TODO: A better way?
            /*
             if let lastAltitude, elapsedRefreshTime < 5 {
             // Wouldn't this give a stale reading anyways?
             // What about: if cache is available, use it.
             // Otherwise, invalidate cache
             entry = lastAltitude
             } else {
             let location = await GPS().location
             let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
             
             entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
             }
             */
            
            /*
             let prevEntry: CompactAltitudeEntry?
             // TODO: Change to 10 min
             if let cachedAltitude = cache.currentAltitude, (currentDate - cachedAltitude.date).min < 5 {
             entry = cachedAltitude
             prevEntry = cache.lastAltitude
             //group.leave()
             } else {
             //group.enter()
             //let location = await GPS().location
             //GPS().locationFuture { location in
             gps.locationFuture { location in
             let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
             
             let entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
             // Should this be set to the user defaults value instead?
             // Otherwise, if a cache hit occurs _after_ this, clearly that won't work.
             cache.currentAltitude = entry
             // TODO: Implement setter that writes to defaults
             // TODO: Possible to run `getTimeline` in some async test?
             //  - can then call it multiple times
             cache.lastAltitude = UserDefaults.Settings.defaults.lastAltitude
             let prevEntry = cache.lastAltitude
             
             let rawEntry = try! JSONEncoder().encode(entry).string!
             UserDefaults.Settings.defaults.set(rawEntry, forKey: UserDefaults.Settings.lastAltitudeReadingKey)
             
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
             
             //group.wait(timeout: .now() + 3)
             group.wait()
             return
             }
             */
            
            
            //group.leave()
            //}
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        updateTimeline(completion: completion)
    }
}
