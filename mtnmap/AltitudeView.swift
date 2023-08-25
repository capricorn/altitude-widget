//
//  AltitudeView.swift
//  mtnmap
//
//  Created by Collin Palmer on 8/22/23.
//

import Foundation
import UIKit
import SwiftUI

extension NSAttributedString {
    enum Attribute {
        case foregroundColor(UIColor)
        case font(UIFont)
        
        var tuple: (key: NSAttributedString.Key, value: Any) {
            switch self {
            case .foregroundColor(let color):
                return (key: NSAttributedString.Key.foregroundColor, value: color)
            case .font(let font):
                return (key: NSAttributedString.Key.font, value: font)
            }
        }
    }
}

extension Array where Element == NSAttributedString.Attribute {
    var attributes: [NSAttributedString.Key: Any]? {
        guard self.count > 0 else {
            return nil
        }
        
        var tmp: [NSAttributedString.Key: Any] = [:]
        for (key, val) in self.map({$0.tuple}) {
            tmp[key] = val
        }
        
        return tmp
    }
}

extension String {
    var attributed: NSAttributedString {
        NSAttributedString(string: self)
    }
    
    func attributed(_ attributes: [NSAttributedString.Attribute]) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes.attributes)
    }
}

class AltitudeView: UIView {
    var values: [Int] = []
    
    // TODO: Any way to use with `Date.formatted()` api?
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        
        return formatter
    }()
    
    static let graphGradient: CGGradient = {
        let colors: CFArray = [ CGColor(red: 0, green: 0, blue: 1, alpha: 1), CGColor(red: 0, green: 0, blue: 0.5, alpha: 0.4) ] as CFArray
        return CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0,1])!
    }()
    
    // TODO: Create gradient here?
    static let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let quadrantWidth = frame.width/Double(AltitudeRepresentableViewModel.MAX_VALUES_SIZE)
        
        context.setStrokeColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.beginPath()
        context.move(to: CGPoint(x: frame.minX, y: frame.minY + frame.height/2))
        context.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + frame.height/2))
        context.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        
        context.setFillColor(CGColor(red: 0, green: 1, blue: 0, alpha: 1))
        
        // Want to draw vertically..
        let gradientStart = CGPoint(x: frame.minX, y: frame.minY)
        let gradientEnd = CGPoint(x: frame.minX, y: frame.maxY)
        
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill([CGRect(origin: CGPoint(x: frame.minX, y: frame.minY), size: CGSize(width: frame.width, height: frame.height))])
        
        // Quadrant divider
        for i in 1..<AltitudeRepresentableViewModel.MAX_VALUES_SIZE {
            context.setStrokeColor(gray: 0.80, alpha: 0.30)
            context.setLineDash(phase: 0, lengths: [4,2])
            context.beginPath()
            context.move(to: CGPoint(x: Double(i)*quadrantWidth, y: frame.minY))
            context.addLine(to: CGPoint(x: Double(i)*quadrantWidth, y: frame.maxY))
            context.strokePath()
        }
        
        context.setLineDash(phase: 0, lengths: [])
        
        for i in 0..<values.count {
            let time = Date(timeIntervalSince1970: Date().timeIntervalSince1970 - Double.random(in: (0...(60*60*3))))
            let timestampString = AltitudeView.timeFormatter.string(from: time)
                .attributed([
                    .foregroundColor(UIColor.lightGray),
                    .font(UIFont.monospacedSystemFont(ofSize: 6, weight: .light))
                ])
            
            let timestampPadding = (quadrantWidth - timestampString.size().width)/2
            let timestampStartX = Double(i)*quadrantWidth + timestampPadding
            let timestampStartY = frame.maxY - timestampString.size().height
            
            timestampString.draw(at: CGPoint(x: timestampStartX, y: timestampStartY))
        }
        
        // Should scale according to this; need to handle negatives
        // Can take min as zero, max as..? Round up to nearest multiple..? (given places)
        //let values = [50, 234, 100, 75]
        // Normalize [0,1] and multiply against frame height (use maxY for now)
        // TODO: Handle negatives -- abs ok?
        let maxY = (values.max()!.padRound())
        let minY = values.min()!
        
        // Start at bottom-left corner?
        context.beginPath()
        context.setStrokeColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))
        context.setFillColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))
        context.setLineWidth(2)
        context.setLineJoin(CGLineJoin.bevel)
        for i in 0..<values.count {
            // y in local coords
            let y = frame.minY + frame.height*(1.0 - Double(values[i])/Double(maxY))
            // x in local coords
            let x = frame.minX + (Double(i)*quadrantWidth + quadrantWidth/2)
            
            // Draw the downward connector line
            if i > 0 {
                let prevY = frame.minY + frame.height*(1.0 - Double(values[i-1])/Double(maxY))
                //context.move(to: CGPoint(x: frame.minX + (Double(i)*quadrantWidth), y: y))
                context.addLine(to: CGPoint(x: frame.minX + (Double(i)*quadrantWidth), y: y))
            } else {
                context.move(to: CGPoint(x: frame.minX, y: y))
            }
            
            // Draw top, left to right
            //context.move(to: CGPoint(x: frame.minX + (Double(i)*quadrantWidth), y: y))
            context.addLine(to: CGPoint(x: frame.minX + (Double(i+1)*quadrantWidth), y: y))
            
            // Draw connector
            if i == (values.count-1) {
                // Obtain first y
                let firstY = frame.minY + frame.height*(1.0 - Double(values[0])/Double(maxY))
                //context.move(to: CGPoint(x: frame.minX + Double(values.count)*quadrantWidth, y: y))
                context.addLine(to: CGPoint(x: frame.minX + Double(values.count)*quadrantWidth, y: frame.maxY))
                // Move back to origin
                context.addLine(to: CGPoint(x: frame.minX, y: frame.maxY))
                context.addLine(to: CGPoint(x: frame.minX, y: firstY))
            }
            
            // Draw value text above
            let valueString = "\(values[i])"
                .attributed([
                    .foregroundColor(UIColor.white),
                    .font(UIFont.monospacedSystemFont(ofSize: 8, weight: .light))
                ])
            
            let valuePadding = (quadrantWidth - valueString.size().width)/2
            let valueStartX = frame.minX + (Double(i)*quadrantWidth) + valuePadding
            let valueStartY = y-valueString.size().height
            
            valueString.draw(at: CGPoint(x: valueStartX, y: valueStartY))
        }
        
        let existingPath = context.path!.copy()!
        context.setStrokeColor(CGColor(red: 0, green: 0, blue: 1, alpha: 1))
        context.drawPath(using: .stroke)
        context.addPath(existingPath)
        context.clip()
        context.drawLinearGradient(AltitudeView.graphGradient, start: gradientStart, end: gradientEnd, options: CGGradientDrawingOptions.drawsAfterEndLocation)
    }
}

extension Int {
    func padRound() -> Int {
        let places: Double = Double(Swift.max("\(self)".count-2, 1))
        return Int(ceil((Double(self) / pow(10, places))) * pow(10, places))
    }
}

class AltitudeRepresentableViewModel: ObservableObject {
    static let MAX_VALUES_SIZE = 10
    @Published var values: [Int] = []
    
    func pushValue(_ value: Int) {
        if values.count > AltitudeRepresentableViewModel.MAX_VALUES_SIZE {
            values.remove(at: 0)
        }
        
        values.append(value)
    }
}

struct AltitudeRepresentableView: UIViewRepresentable {
    typealias UIViewType = AltitudeView
    
    @ObservedObject var model: AltitudeRepresentableViewModel
    
    func makeUIView(context: Context) -> UIViewType {
        return AltitudeView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.values = model.values
        uiView.setNeedsDisplay()
    }
}


struct AltitudePreviewView: View {
    @StateObject var model: AltitudeRepresentableViewModel = AltitudeRepresentableViewModel()
    
    var body: some View {
        VStack {
            AltitudeRepresentableView(model: model)
                .frame(width: 250, height: 250)
                .onAppear {
                    (0..<5).forEach { _ in
                        model.pushValue(Int.random(in: 20...100))
                    }
                }
            Button("Push data") {
                model.pushValue(Int.random(in: 20...100))
            }
        }
    }
}

struct AltitudeView_Previews: PreviewProvider {
    static var previews: some View {
        AltitudePreviewView()
    }
}
