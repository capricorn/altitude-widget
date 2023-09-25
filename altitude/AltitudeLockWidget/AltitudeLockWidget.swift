//
//  AltitudeLockWidget.swift
//  mtnmap
//
//  Created by Collin Palmer on 9/25/23.
//

import WidgetKit
import SwiftUI

struct AltitudeLockWidget: Widget {
    let kind: String = "com.goatfish.altitude"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            altitudeEntryView(container: entry)
        }
        .configurationDisplayName("Recent Altitude")
        .description("A recent altitude reading indicator.")
        .supportedFamilies([.accessoryRectangular])
    }
}
