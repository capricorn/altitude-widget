//
//  AltitudeView.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/22/23.
//

import Foundation
import UIKit
import SwiftUI

class AltitudeView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // TODO
        let context = UIGraphicsGetCurrentContext()!
        let quadrantWidth = frame.width/4
        //let startPoint = CGPoint(x: frame.minX, y: frame.minY)
        
        // Quadrant divider
        for i in 1..<4 {
            context.setStrokeColor(gray: 0.8, alpha: 0.5)
            context.beginPath()
            context.move(to: CGPoint(x: Double(i)*quadrantWidth, y: frame.minY))
            context.addLine(to: CGPoint(x: Double(i)*quadrantWidth, y: frame.maxY))
            context.strokePath()
            //context.closePath()
        }
        
        // Should scale according to this; need to handle negatives
        // Can take min as zero, max as..? Round up to nearest multiple..? (given places)
        let values = [50, 234, 100, 75]
        // Normalize [0,1] and multiply against frame height (use maxY for now)
        // TODO: Handle negatives -- abs ok?
        var maxY = (values.max()!)
        let minY = values.min()!
        
        if (maxY % 100) > 0 {
            maxY = 100*(Int(maxY)/100 + 1)
            print(maxY)
        }
        
        // Start at bottom-left corner?
        context.beginPath()
        context.move(to: CGPoint(x: frame.minX, y: frame.maxY))
        context.setStrokeColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))
        for i in 0..<values.count {
            // y in local coords
            let y = frame.minY + frame.height*(Double(values[i])/Double(maxY))
            // x in local coords
            let x = frame.minX + (Double(i)*quadrantWidth + quadrantWidth/2)
            
            // Draw top, left to right
            context.move(to: CGPoint(x: frame.minX + (Double(i)*quadrantWidth), y: y))
            context.addLine(to: CGPoint(x: frame.minX + (Double(i+1)*quadrantWidth), y: y))
            
            // Draw connector
            if i > 0 {
                let prevY = frame.minY + frame.height*(Double(values[i-1])/Double(maxY))
                context.move(to: CGPoint(x: frame.minX + (Double(i)*quadrantWidth), y: y))
                context.addLine(to: CGPoint(x: frame.minX + (Double(i)*quadrantWidth), y: prevY))
            }
        }
        context.strokePath()
        //context.closePath()
        
        /*
        context.setStrokeColor(CGColor.init(red: 1, green: 0, blue: 0, alpha: 1))
        context.beginPath()
        context.move(to: .zero)
        context.addLine(to: CGPoint(x: 250.0, y: 250.0))
        context.strokePath()
        context.closePath()
         */
        
        // Works -- are the coords local..?
        /*
        context.setFillColor(CGColor.init(red: 1, green: 0, blue: 0, alpha: 1))
        print("Frame: \(self.frame)")
        // start x/y = top-left corner
        context.fill([CGRect(origin: CGPoint(x: frame.minX, y: frame.minY), size: .init(width: frame.width/4, height: frame.height/4))])
         */
    }
}

struct AltitudeRepresentableView: UIViewRepresentable {
    typealias UIViewType = AltitudeView
    
    func makeUIView(context: Context) -> UIViewType {
        return AltitudeView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // TODO: Necessary?
        //uiView.setNeedsDisplay()
        //uiView.draw(CGRect(origin: .zero, size: CGSize(width: 500, height: 500)))
    }
}


struct AltitudeView_Previews: PreviewProvider {
    static var previews: some View {
        AltitudeRepresentableView()
            .frame(width: 250, height: 250)
    }
}
