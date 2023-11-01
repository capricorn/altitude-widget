//
//  AltitudeLockWidget.swift
//  mtnmap
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit
import SwiftUI

struct AltitudeLockWidget: Widget {
    let kind: String = "com.goatfish.altitude"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: AltitudeLockWidgetProvider()) { entry in
            altitudeEntryView(container: entry)
        }
        .configurationDisplayName("Recent Altitude")
        .description("A recent altitude reading indicator.")
        .supportedFamilies([.accessoryRectangular])
    }
}

@available(iOSApplicationExtension 17.0, *)
struct AltitudeLockWidget_Previews: PreviewProvider {
    static let metricUserDefaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "altitude-lock-metric")!
        
        // TODO: UserDefaults extension to make this less painful
        defaults.set(UserDefaults.Settings.AltitudeUnit.meters.rawValue, forKey: UserDefaults.Settings.AltitudeUnit.defaultKey)
        
        return defaults
    }()
    
    static var previews: some View {
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*40, altitude: 600)
            )
        )
        .defaultAppStorage(metricUserDefaults)
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("Minute only")
        
        // Hour-only preview
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*60*12, altitude: 1200)
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("Hour only")
        
        // Days-only preview
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*60*36, altitude: 1200)
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("Days only")
        
        // Prev entry absent
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800)
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("No prev")
        
        // No change in altitude between readings
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*60*36, altitude: 800)
            )
        )
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("No alt delta")
    }
}
