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

struct AltitudeLockWidget_Previews: PreviewProvider {
    static var previews: some View {
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*40, altitude: 600)
            )
        )
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