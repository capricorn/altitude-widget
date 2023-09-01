//
//  Altitude.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit

struct AltitudeStepEntry: TimelineEntry {
    struct Altitude {
        let value: Int
        let time: Date
    }
    
    let altitudes: [Altitude]
    let date: Date
    
    init(altitudes: [Altitude], date: Date=Date()) {
        self.altitudes = altitudes
        self.date = date
    }
}
