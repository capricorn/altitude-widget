//
//  TimelineEntry.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit

struct CompactAltitudeEntry: Codable, RawRepresentable {
    typealias RawValue = String
    
    let date: Date
    let altitude: Int
    
    var rawValue: RawValue {
        try! JSONEncoder().encode(self).description
    }
    
    init?(rawValue: RawValue) {
        let entry = try! JSONDecoder().decode(CompactAltitudeEntry.self, from: rawValue.data(using: .utf8)!)
        
        self.date = entry.date
        self.altitude = entry.altitude
    }
    
    init(date: Date, altitude: Int) {
        self.date = date
        self.altitude = altitude
    }
}

struct AltitudeEntryContainer: TimelineEntry {
    let date: Date
    let configuration: AltitudeIntent
    let currentEntry: CompactAltitudeEntry
    var prevEntry: CompactAltitudeEntry? = nil
}
