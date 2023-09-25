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
