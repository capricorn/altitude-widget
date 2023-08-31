//
//  Altitude.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit

struct Altitude {
    let location: Int
    let timestamp: Int
}

extension Altitude: TimelineEntry {
    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(self.timestamp))
    }
}
