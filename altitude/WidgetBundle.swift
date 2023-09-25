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

struct CompactAltitudeEntry {
    let date: Date
    let altitude: Int
}

struct AltitudeEntryContainer: TimelineEntry {
    let date: Date
    let configuration: AltitudeIntent
    let currentEntry: CompactAltitudeEntry
    var prevEntry: CompactAltitudeEntry? = nil
}

struct AltitudeEntry: TimelineEntry {
    let date: Date
    let altitude: Int
    let configuration: AltitudeIntent
}

@main
struct AltitudeWidgets: WidgetBundle {
    var body: some Widget {
        AltitudeLockWidget()
        AltitudeGraph()
    }
}
