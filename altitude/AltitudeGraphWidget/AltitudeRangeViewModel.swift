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
    private let rangeFontSize = 8.0
    
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
        return size.height * (1/8) //size.height / 4
    }
    
    func horizontalPadding(_ size: CGSize) -> CGFloat {
        return size.width * (1/4)//(3/8)//size.width / 2
    }
    
    func drawRangeDisplay(context: inout GraphicsContext, rect: CGRect, anchor: CGPoint = .zero) {
        let size = rect.size
        
        let minX = rect.minX + anchor.x //rect.minX + horizontalPadding(size) + anchor.x
        //let centerX = rect.minX + size.width/2 + anchor.x
        let maxX = minX + size.width// - horizontalPadding(size)*2 //(size.width - horizontalPadding(size))
        let minY = rect.minY + anchor.y //verticalPadding(size) + anchor.y
        let maxY = minY + size.height //size.height - verticalPadding(size) + anchor.y
        let centerX = (maxX + minX)/2
        
        // Problem: need to leave padding out of above definitions -- apply where applicable
        
        let path = Path { path in
            let maxText = Text(maxLabel).font(.system(size: rangeFontSize).monospaced())
            let maxTextSize = context.resolve(maxText).measure(in: size)
            let maxTextVerticalPad = size.height*(1/8)//0.0//(size.height*(1/8) - maxTextSize.height)/2
            
            // Vertically place text in center
            let topTextPoint = CGPoint(
                x: centerX-maxTextSize.width/2,
                y: minY
            )
            
            // Top line text
            context.draw(Text(maxLabel), at: topTextPoint, anchor: .topLeading)
            
            let minText = Text(minLabel).font(.system(size: rangeFontSize).monospaced())
            let minTextSize = context.resolve(minText).measure(in: size)
            let minTextVerticalPad = 0.0//(size.height*(1/8) - minTextSize.height)/2
            
            let bottomTextPoint = CGPoint(
                x: centerX-minTextSize.width/2,
                y: (maxY-size.height*(1/8)) + minTextVerticalPad
            )
            
            // Bottom line text
            context.draw(Text(minLabel), at: bottomTextPoint, anchor: .topLeading)
            
            // Top bar
            let hOffset = size.width*(1/4)
            path.move(to: CGPoint(x: minX+hOffset, y: minY+size.height*(1/8)))
            path.addLine(to: CGPoint(x: maxX-hOffset, y: minY+size.height*(1/8)))
            
            // Vertical line
            path.move(to: CGPoint(x: centerX, y: minY+size.height*(1/8)))
            path.addLine(to: CGPoint(x: centerX, y: maxY-size.height*(1/8)))
            
            // Bottom line
            path.move(to: CGPoint(x: minX+hOffset, y: maxY-size.height*(1/8)))
            path.addLine(to: CGPoint(x: maxX-hOffset, y: maxY-size.height*(1/8)))
            
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
        context.stroke(path, with: .color(.red), style: StrokeStyle(lineWidth: 1, lineCap: .round))
    }
}
