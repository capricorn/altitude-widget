//
//  AltitudeGraphWidget.swift
//  mtnmap
//
//  Created by Collin Palmer on 9/25/23.
//

import SwiftUI
import WidgetKit

struct AltitudeGraph: Widget {
    let kind: String = "com.goatfish.AltitudeGraph"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: AltitudeIntent.self, provider: AltitudeGraphProvider()) { timelineEntry in
            // TODO: Obtain config here and apply..?
            StepGraphView(entry: timelineEntry)
        }
        .configurationDisplayName("Altitude Graph")
        .description("A timeline of recent altitude readings.")
        .supportedFamilies([.systemSmall])
    }
}

struct AltitudeGraph_Previews: PreviewProvider {
    static var previews: some View {
        StepGraphView(entry: StepGraphView.stepGraphEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
