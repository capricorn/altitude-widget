//
//  AltitudeRangeView.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/11/23.
//

import Foundation
import SwiftUI

// N.B. Assumption with padding is that view exists in a specific aspect ratio (maybe enforce this within view)
// From a proportional perspective: top / bottom bars should be 50% of the height. (Encode this)
struct AltitudeRangeView: View {
    @ObservedObject var viewModel: AltitudeRangeViewModel
    
    func verticalPadding(_ size: CGSize) -> CGFloat {
        return size.height / 4
    }
    
    func horizontalPadding(_ size: CGSize) -> CGFloat {
        return size.width / 4
    }
    
    var body: some View {
        Canvas { context, size in
            let centerX = size.width/2
            let minX = horizontalPadding(size)
            let maxX = size.width - horizontalPadding(size)
            let minY = verticalPadding(size)
            let maxY = size.height - verticalPadding(size)
            
            let path = Path { path in
                let maxText = Text(viewModel.maxLabel).font(.system(size: 16).monospaced())
                let maxTextSize = context.resolve(maxText).measure(in: size)
                let topTextPoint = CGPoint(x: (minX + (maxX-minX)/2) - maxTextSize.width/2, y: minY-maxTextSize.height-8)
                
                // Top line text
                context.draw(Text(viewModel.maxLabel), at: topTextPoint, anchor: .topLeading)
                
                let minText = Text(viewModel.minLabel).font(.system(size: 16).monospaced())
                let minTextSize = context.resolve(minText).measure(in: size)
                let bottomTextPoint = CGPoint(x: (minX + (maxX-minX)/2) - minTextSize.width/2, y: maxY+8)
                
                // Bottom line text
                context.draw(Text(viewModel.minLabel), at: bottomTextPoint, anchor: .topLeading)
                
                // Top bar
                path.move(to: CGPoint(x: minX, y: minY))
                path.addLine(to: CGPoint(x: maxX, y: minY))
                
                path.move(to: CGPoint(x: centerX, y: minY))
                path.addLine(to: CGPoint(x: centerX, y: maxY))
                
                path.move(to: CGPoint(x: minX, y: maxY))
                path.addLine(to: CGPoint(x: maxX, y: maxY))
                
                guard let current = viewModel.current,
                      let max = viewModel.max,
                      let min = viewModel.min
                else {
                    return
                }
                
                // Calculate y-offset given point (between maxY/minY)
                let scalar = (1/(Swift.max(max-min,1.0)))*(current-max) + 1.0
                let currentY = scalar * (maxY-minY) + minY
                let centerPoint = CGPoint(x: centerX, y: currentY)
                path.move(to: centerPoint)
                path.addArc(center: centerPoint, radius: 4.0, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
            }
            
            // TODO: Some sort of indicator to represent current point
            context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 4, lineCap: .round))
        }
        .border(Color.red)
        .background(.black)
        .foregroundColor(.white)
    }
}

struct AltitudeRangeView_Preview: PreviewProvider {
    struct PreviewView: View {
        @StateObject var viewModel: AltitudeRangeViewModel = AltitudeRangeViewModel()
        
        var body: some View {
            AltitudeRangeView(viewModel: viewModel)
                .frame(width: 200, height: 400)
                .onAppear {
                    viewModel.max = 8238
                }
                .onTapGesture {
                    let a = CGFloat(Int.random(in: 100...1000))
                    let b = CGFloat(Int.random(in: 100...1000))
                    
                    viewModel.max = max(a,b)
                    viewModel.min = min(a,b)
                    viewModel.current = CGFloat(Int.random(in: Int(viewModel.min!)...Int(viewModel.max!)))
                }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
