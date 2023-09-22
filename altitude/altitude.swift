//
//  altitude.swift
//  altitude
//
//  Created by Collin Palmer on 3/27/23.
//

import WidgetKit
import SwiftUI
import Intents
import CoreMotion

extension Double {
    func measurement<UnitType: Unit>(_ type: UnitType) -> Measurement<UnitType> {
        Measurement(value: self, unit: type.self)
    }
}

class Altimeter {
    private let queue = OperationQueue()
    private let altimeter = CMAltimeter()
    static let shared = Altimeter()
    
    var absoluteAltitude: Measurement<UnitLength>? {
        get async {
            await withCheckedContinuation { (continuation: CheckedContinuation<Measurement<UnitLength>?, Never>) in
                altimeter.startAbsoluteAltitudeUpdates(to: queue) { data, error in
                    self.altimeter.stopAbsoluteAltitudeUpdates()
                    if let data {
                        continuation.resume(returning: Measurement(value: Double(data.altitude), unit: .meters))
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> AltitudeEntry {
        AltitudeEntry(date: Date(), altitude: 800, configuration: AltitudeIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AltitudeEntry) -> ()) {
        let entry = AltitudeEntry(date: Date(), altitude: 800, configuration: AltitudeIntent())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task { @MainActor in
            let location = await GPS().location
            let currentDate = Date()
            let altitudeFeet = Int(location.altitude.measurement(UnitLength.feet).value)
            let measurement = Measurement(value: location.altitude, unit: UnitLength.feet)
            let entry = AltitudeEntry(date: currentDate, altitude: altitudeFeet, configuration: AltitudeIntent())
            let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!))
            completion(timeline)
        }
    }
}

struct AltitudeEntry: TimelineEntry {
    let date: Date
    let altitude: Int
    let configuration: AltitudeIntent
}

struct altitudeEntryView : View {
    var entry: Provider.Entry
    
    var altitude: AltitudeEntry {
        entry as AltitudeEntry
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "mountain.2.circle")
            Text("\(altitude.altitude) ft")
        }
    }
}

@main
struct AltitudeWidgets: WidgetBundle {
    var body: some Widget {
        altitude()
        AltitudeGraph()
    }
}

struct AltitudeGraph: Widget {
    let kind: String = "com.goatfish.AltitudeGraph"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: AltitudeIntent.self, provider: AltitudeGraphProvider()) { timelineEntry in
            // TODO: Obtain config here and apply..?
            StepGraphView(entry: timelineEntry)
        }
        .configurationDisplayName("Altitude Graph")
        .description("A timeline of recent altitude readings.")
        .supportedFamilies([.accessoryRectangular, .systemSmall])
    }
}

struct altitude: Widget {
    let kind: String = "com.goatfish.altitude"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            altitudeEntryView(entry: entry)
        }
        .configurationDisplayName("Recent Altitude")
        .description("A recent altitude reading indicator.")
        .supportedFamilies([
            .accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
    }
}

struct altitude_Previews: PreviewProvider {
    static var previews: some View {
        StepGraphView(entry: StepGraphView.stepGraphEntry)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        altitudeEntryView(entry: AltitudeEntry(date: Date(), altitude: 800, configuration: AltitudeIntent()))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
