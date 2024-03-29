//
//  AltitudeLockWidget.swift
//  mtnmap
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit
import SwiftUI

struct AltitudeLockWidget: Widget {
    static let queue = DispatchQueue(label: "altitude-widget")
    static let group = DispatchGroup()
    static let cacheExpirationMin = 5.0
    
    let kind: String = "com.goatfish.altitude"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: AltitudeLockWidgetProvider()) { entry in
            altitudeEntryView(container: entry)
                .defaultAppStorage(.init(suiteName: UserDefaults.Settings.appGroupId)!)
        }
        .configurationDisplayName("Recent Altitude")
        .description("A recent altitude reading indicator.")
        .supportedFamilies([.accessoryRectangular, .accessoryInline])
    }
}

@available(iOSApplicationExtension 17.0, *)
@available(iOS 17, *)
struct AltitudeLockWidget_Previews: PreviewProvider {
    static let metricUserDefaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "altitude-lock-metric")!
        
        // TODO: UserDefaults extension to make this less painful
        defaults.set(UserDefaults.Settings.AltitudeUnit.meters.rawValue, forKey: UserDefaults.Settings.AltitudeUnit.defaultKey)
        let lastAltitude = CompactAltitudeEntry(date: Date(), altitude: 4000)
        defaults.set(lastAltitude.rawValue, forKey: UserDefaults.Settings.lastAltitudeReadingKey)
        
        return defaults
    }()
    
    static let hour24UserDefaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "altitude-lock-24hr")!
        
        // TODO: UserDefaults extension to make this less painful
        defaults.set(UserDefaults.Settings.TimeNotation.hour24.rawValue, forKey: UserDefaults.Settings.TimeNotation.defaultKey)
        
        return defaults
    }()
    
    static let displayAccuracyDefaults: UserDefaults = {
        let defaults = UserDefaults(suiteName: "altitude-accuracy")!
        
        //defaults.displayAccuracy = true
        defaults.set(true, forKey: UserDefaults.Settings.displayAccuracyKey)
        
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
        .defaultAppStorage(hour24UserDefaults)
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
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
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
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
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
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
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("No alt delta")
        
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 800),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*60*36, altitude: 800)
            )
        )
        .defaultAppStorage(displayAccuracyDefaults)
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        .previewDisplayName("Display accuracy")
        
        altitudeEntryView(
            container: AltitudeEntryContainer(
                date: Date(),
                configuration: AltitudeIntent(),
                currentEntry: CompactAltitudeEntry(date: Date(), altitude: 8132),
                prevEntry: CompactAltitudeEntry(date: Date() - 60*60*36, altitude: 800)
            )
        )
        .defaultAppStorage(displayAccuracyDefaults)
        .containerBackground(for: .widget) {
            AccessoryWidgetBackground()
        }
        .previewContext(WidgetPreviewContext(family: .accessoryInline))
        .previewDisplayName("Display inline")
    }
}
