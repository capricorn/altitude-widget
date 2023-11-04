//
//  AltitudeLockWidgetProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit

struct AltitudeLockWidgetProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AltitudeEntryContainer {
        AltitudeEntryContainer(date: Date(), configuration: AltitudeIntent(), currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AltitudeEntryContainer) -> ()) {
        let entry = AltitudeEntryContainer(date: Date(), configuration: AltitudeIntent(), currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        Task { @MainActor in
            let currentDate = Date()
            let entry: CompactAltitudeEntry
            let lastAltitude = UserDefaults.Settings.defaults.lastAltitude
            
            if let lastAltitude, (currentDate.timeIntervalSince(lastAltitude.date)).minutes < 5 {
                entry = lastAltitude
            } else {
                let location = await GPS().location
                let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
                
                entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
            }
            
            let container = AltitudeEntryContainer(
                date: currentDate,
                configuration: AltitudeIntent(),
                currentEntry: entry,
                prevEntry: lastAltitude
            )
            
            let timeline = Timeline(
                entries: [container],
                policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!)
            )
            
            let rawEntry = try! JSONEncoder().encode(entry).string!
            UserDefaults.Settings.defaults.set(rawEntry, forKey: UserDefaults.Settings.lastAltitudeReadingKey)
            
            completion(timeline)
        }
    }
}
