//
//  AltitudeRangeViewModel.swift
//  mtnmap
//
//  Created by Collin Palmer on 9/11/23.
//

import Foundation
import SwiftUI

class AltitudeRangeViewModel: ObservableObject {
    @Published var max: CGFloat?
    @Published var min: CGFloat?
    @Published var current: CGFloat?
    
    private let missingLabel = "--"
    
    var maxLabel: String {
        guard let max else {
            return missingLabel
        }
        
        return Double(max).formatted(.number.precision(.fractionLength(0..<2)))
    }
    
    var minLabel: String {
        guard let min else {
            return missingLabel
        }
        
        return Double(min).formatted(.number.precision(.fractionLength(0..<2)))
    }
    
    func verticalPadding(_ size: CGSize) -> CGFloat {
        return size.height / 4
    }
    
    func horizontalPadding(_ size: CGSize) -> CGFloat {
        return size.width * (3/8)//size.width / 2
    }
    
    func drawRangeDisplay(context: inout GraphicsContext, rect: CGRect) {
        let size = rect.size
        
        let minX = rect.minX + horizontalPadding(size)
        let centerX = rect.minX + size.width/2
        let maxX = minX + size.width - horizontalPadding(size)*2 //(size.width - horizontalPadding(size))
        let minY = verticalPadding(size)
        let maxY = size.height - verticalPadding(size)
        
        let path = Path { path in
            let maxText = Text(maxLabel).font(.system(size: 16).monospaced())
            let maxTextSize = context.resolve(maxText).measure(in: size)
            let topTextPoint = CGPoint(x: (minX + (maxX-minX)/2) - maxTextSize.width/2, y: minY-maxTextSize.height-8)
            
            // Top line text
            context.draw(Text(maxLabel), at: topTextPoint, anchor: .topLeading)
            
            let minText = Text(minLabel).font(.system(size: 16).monospaced())
            let minTextSize = context.resolve(minText).measure(in: size)
            let bottomTextPoint = CGPoint(x: (minX + (maxX-minX)/2) - minTextSize.width/2, y: maxY+8)
            
            // Bottom line text
            context.draw(Text(minLabel), at: bottomTextPoint, anchor: .topLeading)
            
            // Top bar
            path.move(to: CGPoint(x: minX, y: minY))
            path.addLine(to: CGPoint(x: maxX, y: minY))
            
            path.move(to: CGPoint(x: centerX, y: minY))
            path.addLine(to: CGPoint(x: centerX, y: maxY))
            
            path.move(to: CGPoint(x: minX, y: maxY))
            path.addLine(to: CGPoint(x: maxX, y: maxY))
            
            guard let current = current,
                  let max = max,
                  let min = min
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
        context.stroke(path, with: .color(.white), style: StrokeStyle(lineWidth: 1, lineCap: .round))
    }
}
