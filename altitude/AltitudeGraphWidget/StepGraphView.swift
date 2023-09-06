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
    let entry: AltitudeStepEntry
    
    init(entry: AltitudeStepEntry) {
        self.entry = entry
    }
    
    private func graphHeight(context: GraphicsContext, size: CGSize) -> CGFloat {
        let timestampText = Text("00:00").font(.system(size: 8, design: .monospaced))
        
        // The graph height stretches from the top of the frame to the top padding of the bottom row timestamp text.
        return size.height - (context.resolve(timestampText).measure(in: size).height + 4)
    }
    
    private func graphRect(context: GraphicsContext, size: CGSize) -> CGRect {
        let graphMinY = 4.0
        let graphHeight = graphHeight(context: context, size: size)
        
        return CGRect(x: 0.0, y: graphMinY, width: size.width, height: graphHeight - graphMinY)
    }
    
    private func drawTimeline(context: GraphicsContext, size: CGSize) {
        let startDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        
        for i in 0..<min(columns, entry.altitudes.count) {
            //let timestamp = Int(startDate.timeIntervalSince1970) + i*Int.random(in: 60...3600)
            let date = entry.altitudes[i].time
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
            Canvas { context, size in
                context.stroke(
                    Path { path in
                        let graphRect = graphRect(context: context, size: size)
                        let values = entry.altitudes.map { CGFloat($0.value) }
                        let columnWidth = graphRect.width/CGFloat(columns)
                        
                        let scaler = { (x: CGFloat) -> CGFloat in
                            let maxValue = values.max()!
                            let minValue = values.min()!
                            // TODO: Negative support?
                            let slope = 1/(max(maxValue-minValue, 1))
                            
                            return slope*(x-maxValue) + 1.0
                        }
                        
                        path.move(to: .zero)
                        
                        for col in 0..<min(columns, values.count) {
                            let columnHeight = (graphRect.height)*(scaler(values[col]))
                            let columnX = (CGFloat(col)*columnWidth + columnWidth/2)
                            
                            let columnOriginPoint = CGPoint(x: columnX, y: graphRect.maxY)
                            let columnTopPoint = CGPoint(x: columnX, y: graphRect.maxY - columnHeight)
                            
                            path.move(to: columnOriginPoint)
                            path.addLine(to: columnTopPoint)
                            
                            // TODO: Select top/bottom if bounds exceeded
                            let columnText = Text("\(Int(values[col]))").font(.system(size: 8, design: .monospaced))
                            let columnTextSize = context.resolve(columnText).measure(in: size)
                            let columnTextPadding = (columnWidth - columnTextSize.width)/2
                            
                            // If the text will clip below the graph, render it above.
                            /*
                            if (columnY + columnTextSize.height) > (graphRect.height-4) {
                                columnY -= columnTextSize.height
                            }
                             */
                            
                            /*
                            context.draw(
                                // TODO: Value formatting
                                Text("\(Int(values[col]))").font(.system(size: 8, design: .monospaced)),
                                at: CGPoint(x: CGFloat(col)*(columnWidth) + columnTextPadding, y: columnY),
                                anchor: .topLeading
                            )
                             */
                        }
                    }, with: .foreground, style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                
                drawTimeline(context: context, size: size)
            }
            .border(Color.black)
        }
        .cornerRadius(5)
        .onAppear {
            print("Running altitude graph")
        }
    }
}

struct StepGraphView_Previews: PreviewProvider {
    static var previews: some View {
        // Use app target for previewing!
        StepGraphView(entry: StepGraphView.stepGraphEntry)
    }
}
