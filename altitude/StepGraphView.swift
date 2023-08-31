//
//  StepGraphView.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/31/23.
//

import SwiftUI
import WidgetKit

struct StepGraphView: View {
    let columns = 5
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
                .cornerRadius(5)
            Canvas { context, size in
                // test1 -- draw columns
                context.stroke(
                    Path { path in
                        let columnWidth = size.width/CGFloat(columns)
                        // Should be (0,0) in the view
                        path.move(to: .zero)
                        // TODO: Stroke color?
                        for col in 1...columns {
                            path.addLine(to: CGPoint(x: CGFloat(col)*columnWidth, y: CGFloat(Int.random(in: 10...40))))
                        }
                    }, with: .foreground
                )
            }
            .border(Color.black)
        }
    }
}

struct StepGraphView_Previews: PreviewProvider {
    static var previews: some View {
        StepGraphView()
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
