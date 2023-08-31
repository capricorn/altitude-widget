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
    
    private func graphHeight(context: GraphicsContext, size: CGSize) -> CGFloat {
        let timestampText = Text("00:00").font(.system(size: 8, design: .monospaced))
        
        return size.height - (context.resolve(timestampText).measure(in: size).height + 4)
    }
    
    private func drawTimeline(context: GraphicsContext, size: CGSize) {
        let startDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        
        for i in 0..<columns {
            let timestamp = Int(startDate.timeIntervalSince1970) + i*Int.random(in: 60...3600)
            let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
            let text = Text(formatter.string(from: date)).font(.system(size: 6, design: .monospaced))
            
            let columnWidth = size.width/CGFloat(columns)
            let timestampTextSize = context.resolve(text).measure(in: size)
            let timestampPadding = (columnWidth - timestampTextSize.width)/2
            let labelPoint = CGPoint(x: CGFloat(i)*columnWidth + timestampPadding, y: size.height - timestampTextSize.height)
            
            context.draw(text, at: labelPoint, anchor: .topLeading)
        }
    }
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
                .cornerRadius(5)
            Canvas { context, size in
                context.stroke(
                    Path { path in
                        let values = (0..<columns).map { _ in CGFloat(Int.random(in: 100...1000)) }
                        let columnWidth = size.width/CGFloat(columns)
                        let graphHeight = graphHeight(context: context, size: size)
                        
                        let scaler = { (x: CGFloat) -> CGFloat in
                            let maxValue = values.max()!
                            let minValue = values.min()!
                            let slope = 1/(maxValue-minValue)
                            
                            return slope*(x-maxValue) + 1.0
                        }
                        
                        path.move(to: .zero)
                        
                        for col in 0..<columns {
                            // +- 4 padding
                            var columnY = (graphHeight-8)*scaler(values[col]) + 4
                            path.addLine(to: CGPoint(x: CGFloat(col)*columnWidth, y: columnY))
                            
                            let point = CGPoint(
                                x: CGFloat(col+1)*(columnWidth),
                                y: columnY
                            )
                            // Top line of square
                            path.addLine(to: point)
                            // TODO: Select top/bottom if bounds exceeded
                            let columnText = Text("\(Int(values[col]))").font(.system(size: 8, design: .monospaced))
                            let columnTextSize = context.resolve(columnText).measure(in: size)
                            let columnTextPadding = (columnWidth - columnTextSize.width)/2
                            
                            // If the text will clip below the graph, render it above.
                            if (columnY + columnTextSize.height) > (graphHeight-4) {
                                columnY -= columnTextSize.height
                            }
                            
                            context.draw(
                                // TODO: Value formatting
                                Text("\(Int(values[col]))").font(.system(size: 8, design: .monospaced)),
                                at: CGPoint(x: CGFloat(col)*(columnWidth) + columnTextPadding, y: columnY),
                                anchor: .topLeading
                            )
                        }
                    }, with: .foreground
                )
                
                drawTimeline(context: context, size: size)
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
