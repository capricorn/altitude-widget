//
//  StepGraphView.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/31/23.
//

import SwiftUI
import WidgetKit

struct StepGraphView: View {
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
        let altitudeTextSize = altitudeTextSize(context: context, size: size)
        
        let timestampRowHeight = timestampTextSize.height + 4
        let altitudeTextHeight = altitudeTextSize.height + 4
        
        return size.height - (timestampRowHeight + altitudeTextHeight)
    }
    
    private func graphRect(context: GraphicsContext, size: CGSize) -> CGRect {
        let graphMinY = altitudeTextSize(context: context, size: size).height + 4
        let graphHeight = graphHeight(context: context, size: size)
        
        return CGRect(x: 0.0, y: graphMinY, width: size.width, height: graphHeight)
    }
    
    private func drawTimeline(context: inout GraphicsContext, size: CGSize) {
        let startDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        
        //context.rotate(by: .degrees(5))
        for i in 0..<min(StepGraphView.columns, entry.altitudes.count) {
            //let timestamp = Int(startDate.timeIntervalSince1970) + i*Int.random(in: 60...3600)
            let date = entry.altitudes[i].time
            let text = Text(formatter.string(from: date)).font(.system(size: 6, design: .monospaced))
            
            //context.rotate(by: .degrees(-90))
            //context.transform = .identity
            
            let columnWidth = size.width/CGFloat(StepGraphView.columns)
            let timestampTextSize = context.resolve(text).measure(in: size)
            let timestampPadding = (columnWidth - timestampTextSize.width/2)/2
            let x1 = (CGFloat(i)*columnWidth + columnWidth/2)// + timestampPadding
            // If not vertically centered, translation problem
            let y1 = 0.0//size.height//size.height-(timestampTextSize.width/2)///2//-20
            let labelPoint = CGPoint(x: x1, y: y1)
            
            // TODO: Calculate changed drawing rect once performed at 45 degrees..?
            // (For now, don't use the text size at all for operations)
            context.drawLayer { subCtx in
                //subCtx.translateBy(x: 0, y: 0)
                // Does the point need translated too?
                let rotation = 45.0
                // Want to rotate opp direction to cancel out
                let rotationRadians = Angle(degrees: -rotation).radians
                subCtx.rotate(by: .degrees(rotation))
                let hyp = labelPoint.distance()
                
                //let rotatedPoint = CGPoint(x: hyp*cos(rotationRadians), y: hyp*sin(rotationRadians))
                let rotatedPoint = CGPoint(
                    x: hyp*(cos(rotationRadians)-1)+x1,
                    y: hyp*sin(rotationRadians)+y1
                )
                subCtx.draw(text, at: rotatedPoint, anchor: .topLeading)
                //subCtx.draw(text, at: labelPoint.rotate(.degrees(-rotation)), anchor: .topLeading)
                //subCtx.rotate(by: .degrees(-10))
                //subCtx.transform = .init(rotationAngle: 3.14/4)
            }
            //context.draw(text, at: labelPoint, anchor: .topLeading)
            //context.transform = .identity
            //context.rotate(by: .degrees(-5))
            // TODO: Necessary?
            //context.rotate(by: .degrees(-45))
        }
        //context.transform = .identity
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
                            
                            context.draw(
                                // TODO: Value formatting
                                columnText,
                                at: CGPoint(x: columnX - columnTextPadding, y: columnTopPoint.y - columnTextSize.height - 4),
                                anchor: .topLeading
                            )
                        }
                    }, with: .foreground, style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                
                drawTimeline(context: &context, size: size)
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
