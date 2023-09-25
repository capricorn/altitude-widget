//
//  AltitudeLockWidgetProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit

struct AltitudeLockWidgetProvider: IntentTimelineProvider {
    class PreviousEntryContainer {
        var entry: CompactAltitudeEntry?
    }
    
    let prevEntryContainer = PreviousEntryContainer()
    
    func placeholder(in context: Context) -> AltitudeEntryContainer {
        AltitudeEntryContainer(date: Date(), configuration: AltitudeIntent(), currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800))
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AltitudeEntryContainer) -> ()) {
        let entry = AltitudeEntryContainer(date: Date(), configuration: AltitudeIntent(), currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800))
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<AltitudeEntryContainer>) -> ()) {
        Task { @MainActor in
            let location = await GPS().location
            let currentDate = Date()
            let altitudeFeet = Int(location.mAltitude.converted(to: .feet).value)
            
            let entry = CompactAltitudeEntry(date: currentDate, altitude: altitudeFeet)
            let container = AltitudeEntryContainer(date: currentDate, configuration: AltitudeIntent(), currentEntry: entry, prevEntry: prevEntryContainer.entry)
            let timeline = Timeline(entries: [container], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!))
            
            prevEntryContainer.entry = entry
            
            completion(timeline)
        }
    }
}
