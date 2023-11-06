//
//  TimelineEntryContainer.swift
//  mtnmap
//
//  Created by Collin Palmer on 11/1/23.
//

import Foundation
import WidgetKit

struct AltitudeEntryContainer: TimelineEntry {
    let date: Date
    let configuration: AltitudeIntent
    let currentEntry: CompactAltitudeEntry?
    var prevEntry: CompactAltitudeEntry? = nil
}
