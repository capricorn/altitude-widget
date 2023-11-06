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
    let altitude: Int?
    
    enum CodingKeys: String, CodingKey {
        case date
        case altitude
    }
    
    var rawValue: RawValue {
        try! JSONEncoder().encode(self).string!
    }
    
    init?(rawValue: RawValue) {
        let entry = try! JSONDecoder().decode(CompactAltitudeEntry.self, from: rawValue.data(using: .utf8)!)
        
        self.date = entry.date
        self.altitude = entry.altitude
    }
    
    init(date: Date, altitude: Int?) {
        self.date = date
        self.altitude = altitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.date.formatted(.iso8601), forKey: .date)
        try container.encode(self.altitude, forKey: .altitude)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let iso8601Date = try container.decode(String.self, forKey: .date)
        self.date = ISO8601DateFormatter().date(from: iso8601Date)!
        
        self.altitude = try container.decode(Int.self, forKey: .altitude)
    }
}
