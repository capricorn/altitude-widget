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
                context.stroke(
                    Path { path in
                        let values = (0..<columns).map { _ in CGFloat(Int.random(in: 100...1000)) }
                        let columnWidth = size.width/CGFloat(columns)
                        
                        let scaler = { (x: CGFloat) -> CGFloat in
                            let maxValue = values.max()!
                            let minValue = values.min()!
                            let slope = 1/(maxValue-minValue)
                            
                            return slope*(x-maxValue) + 1.0
                        }
                        
                        path.move(to: .zero)
                        
                        for col in 0..<columns {
                            // +- 4 padding
                            let columnY = (size.height-8)*scaler(values[col]) + 4
                            path.addLine(to: CGPoint(x: CGFloat(col)*columnWidth, y: columnY))
                            
                            let point = CGPoint(
                                x: CGFloat(col+1)*(columnWidth),
                                y: columnY
                            )
                            path.addLine(to: point)
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
