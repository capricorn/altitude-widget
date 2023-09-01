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
        AltitudeEntry(date: Date(), altitude: 800, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AltitudeEntry) -> ()) {
        let entry = AltitudeEntry(date: Date(), altitude: 800, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            if let altitude = await Altimeter.shared.absoluteAltitude {
                let currentDate = Date()
                let altitudeFeet = Int(altitude.converted(to: .feet).value)
                let entry = AltitudeEntry(date: currentDate, altitude: altitudeFeet, configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!))
                completion(timeline)
            } else {
                // TODO: Populate '--' if reading altitude fails
            }
        }
    }
}

struct AltitudeEntry: TimelineEntry {
    let date: Date
    let altitude: Int
    let configuration: ConfigurationIntent
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
        //altitude()
        AltitudeGraph()
    }
}

struct AltitudeGraph: Widget {
    let kind: String = "com.goatfish.AltitudeGraph"
    
    var body: some WidgetConfiguration {
        // TODO: Is a custom ConfigurationIntent necessary?
        // TODO: Implement separate Provider
        StaticConfiguration(kind: kind, provider: AltitudeGraphProvider()) { timelineEntry in
            // TODO: Provide entry to actual view
            StepGraphView(entry: timelineEntry)
        }
        .configurationDisplayName("Altitude Graph")
        .description("This is an example widget.")
        .supportedFamilies([.accessoryRectangular, .systemMedium])
    }
}

//@main
struct altitude: Widget {
    let kind: String = "com.goatfish.altitude"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            altitudeEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([
            .accessoryRectangular, .accessoryInline, .systemSmall, .systemMedium])
    }
}

struct altitude_Previews: PreviewProvider {
    static var previews: some View {
        StepGraphView(entry: AltitudeStepEntry(altitudes: []))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        /*
        altitudeEntryView(entry: AltitudeEntry(date: Date(), altitude: 800, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
         */
    }
}
