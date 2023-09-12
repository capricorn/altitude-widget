//
//  StepGraphView.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/31/23.
//

import SwiftUI
import WidgetKit

struct StepGraphView: View {
    @StateObject var rangeModel = AltitudeRangeViewModel()
    
    static let columns = 10
    let entry: AltitudeStepEntry
    
    init(entry: AltitudeStepEntry) {
        self.entry = entry
    }
    
    private func altitudeTextSize(context: GraphicsContext, size: CGSize) -> CGSize {
        let exampleText = Text("12,345").font(.system(size: 8, design: .monospaced))
        return context.resolve(exampleText).measure(in: size)
    }
    
    private func timestampTextSize(context: GraphicsContext, size: CGSize) -> CGSize {
        let timestampText = Text("00:00").font(.system(size: 8, design: .monospaced))
        return context.resolve(timestampText).measure(in: size)
    }
    
    private func graphHeight(context: GraphicsContext, size: CGSize) -> CGFloat {
        let timestampTextSize = timestampTextSize(context: context, size: size)
        let timestampRowHeight = (timestampTextSize.width*cos(3.14/4)) + 4
        
        return size.height - (timestampRowHeight + 8)
    }
    
    private func graphRect(context: GraphicsContext, size: CGSize) -> CGRect {
        let graphMinY = 8.0
        let graphHeight = graphHeight(context: context, size: size)
        
        let graphWidth = size.width*(2/3)
        
        return CGRect(x: 8.0, y: graphMinY, width: graphWidth, height: graphHeight)
    }
    
    private func rangeDisplayRect(context: GraphicsContext, size: CGSize) -> CGRect {
        let minX = size.width*(3/4)//size.width*(2/3) // -- use last fourth for range display
        let maxX = size.width
        let minY = 0.0
        let maxY = size.height - (timestampTextSize(context: context, size: size).width*cos(3.14/4))
        
        return CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    private func drawRangeDisplay(context: inout GraphicsContext, size: CGSize) {
        // TODO
    }
    
    private func drawTimeline(context: inout GraphicsContext, size: CGSize) {
        let graphRect = graphRect(context: context, size: size)
        let startDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        
        for i in 0..<min(StepGraphView.columns, entry.altitudes.count) {
            //let timestamp = Int(startDate.timeIntervalSince1970) + i*Int.random(in: 60...3600)
            let date = entry.altitudes[i].time
            let text = Text(formatter.string(from: date)).font(.system(size: 6, design: .monospaced))
            
            let columnWidth = graphRect.width/CGFloat(StepGraphView.columns)
            let timestampTextSize = context.resolve(text).measure(in: size)
            let timestampPadding = (columnWidth - timestampTextSize.width/2)/2
            let x1 = graphRect.minX + (CGFloat(i)*columnWidth)// + timestampPadding
            // If not vertically centered, translation problem
            let y1 = size.height-(timestampTextSize.width*cos(3.14/4))-6
            
            context.drawLayer { subCtx in
                subCtx.rotate(by: .degrees(45))
                let inverseTransform = subCtx.transform.inverted()
                let rotatedPoint = CGPoint(x: x1, y: y1).applying(inverseTransform)
                
                subCtx.draw(text, at: rotatedPoint, anchor: .topLeading)
            }
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
                        let columnWidth = graphRect.width/CGFloat(StepGraphView.columns)
                        
                        let scaler = { (x: CGFloat) -> CGFloat in
                            let maxValue = values.max()!
                            let minValue = values.min()!
                            // TODO: Negative support?
                            let slope = 1/(max(maxValue-minValue, 1))
                            
                            return slope*(x-maxValue) + 1.0
                        }
                        
                        path.move(to: .zero)
                        
                        for col in 0..<min(StepGraphView.columns, values.count) {
                            let columnHeight = (graphRect.height)*(scaler(values[col]))
                            let columnX = (CGFloat(col)*columnWidth + columnWidth/2)
                            
                            let columnOriginPoint = CGPoint(x: columnX, y: graphRect.maxY)
                            let columnTopPoint = CGPoint(x: columnX, y: graphRect.maxY - columnHeight)
                            
                            path.move(to: columnOriginPoint)
                            path.addLine(to: columnTopPoint)
                            
                            let columnText = Text("\(Int(values[col]))").font(.system(size: 8, design: .monospaced))
                            let columnTextSize = context.resolve(columnText).measure(in: size)
                            let columnTextPadding = columnTextSize.width/2//(columnWidth - columnTextSize.width)/2
                            
                            /*
                            context.draw(
                                // TODO: Value formatting
                                columnText,
                                at: CGPoint(x: columnX - columnTextPadding, y: columnTopPoint.y - columnTextSize.height - 4),
                                anchor: .topLeading
                            )
                             */
                        }
                    }, with: .foreground, style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                
                drawTimeline(context: &context, size: size)
                let rangeRect = rangeDisplayRect(context: context, size: size)
                rangeModel.drawRangeDisplay(context: &context, rect: rangeRect)
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
