//
//  TimelineEntry.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit

struct CompactAltitudeEntry: Codable {
    let date: Date
    let altitude: Int
}

struct AltitudeEntryContainer: TimelineEntry {
    let date: Date
    let configuration: AltitudeIntent
    let currentEntry: CompactAltitudeEntry
    var prevEntry: CompactAltitudeEntry? = nil
}
