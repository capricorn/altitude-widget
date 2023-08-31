//
//  Altitude.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit

struct Altitude: TimelineEntry {
    let location: Int
    let timestamp: Int
    let date: Date
    
    init(location: Int, timestamp: Int, date: Date=Date()) {
        self.location = location
        self.timestamp = timestamp
        self.date = date
    }
}
