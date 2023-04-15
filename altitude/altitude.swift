//
//  altitude.swift
//  altitude
//
//  Created by Collin Palmer on 3/27/23.
//

import WidgetKit
import SwiftUI
import Intents

// WIP: How to provide callbacks to display / simulate the altitude?
// How to view the widget on the home screen? (Accessory?)
// Need to make async altimeter call I think.. can't have a running background task
// Maybe the app itself should collect data and inform the widget to update..
// (Where can the widget itself access this info? Core Data?)
// WIP: Update XCode to 14.2 for iOS 16.3 support.. also, make a 'one-shot' API for the altimeter.
// TODO: Test syncing refresh

import CoreMotion

extension CMAltimeter {
    var absoluteAltitude: Int {
        // TODO: Need to find the wrapper to convert continuations to async
        get async {
            return 0
        }
    }
}

private let FEET_PER_METER = 3.281

struct Provider: IntentTimelineProvider {
    
    //let altitudeManager = CMAltimeter()
    let opQueue = OperationQueue()

    func placeholder(in context: Context) -> AltitudeEntry {
        AltitudeEntry(date: Date(), altitude: 800, configuration: ConfigurationIntent())
    }

    // Provides a fixed snapshot of the widget as an example
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (AltitudeEntry) -> ()) {
        let entry = AltitudeEntry(date: Date(), altitude: 800, configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        print("Fetching timeline: \(Date())")
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        /*
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        */
        let altitudeManager = CMAltimeter()
        altitudeManager.startAbsoluteAltitudeUpdates(to: opQueue) { data, error in
            if let error {
                print("Error: \(error)")
                return
            }

            if let data {
                print("Altitude: \(data.altitude)")
                altitudeManager.stopAbsoluteAltitudeUpdates()
                let entry = AltitudeEntry(date: Date(), altitude: Int(data.altitude * FEET_PER_METER), configuration: configuration)
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            }
        }

        /*
        // One option: perform the background processing but still pass completion with the timeline data.
        let entryDate = Calendar.current.date(byAdding: .second, value: 5, to: currentDate)!
        entries.append(SimpleEntry(date: entryDate, configuration: configuration))

        let timeline = Timeline(entries: entries, policy: .after(entryDate))
        completion(timeline)
        */
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
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
        //Text(entry.date, style: .time)
    }
}

@main
struct altitude: Widget {
    let kind: String = "altitude"

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
        altitudeEntryView(entry: AltitudeEntry(date: Date(), altitude: 800, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
