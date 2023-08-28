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
    var values: [Altitude] = []
    
    // TODO: Any way to use with `Date.formatted()` api?
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm"
        
        return formatter
    }()
    
    static let graphGradient: CGGradient = {
        let colors: CFArray = [ CGColor(red: 1.0, green: 0.5, blue: 1, alpha: 1.0), CGColor(red: 0, green: 0, blue: 0.2, alpha: 0.1) ] as CFArray
        return CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0,1])!
    }()
    
    // TODO: Create gradient here?
    static let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    func drawColumnDividers() {
        let context = UIGraphicsGetCurrentContext()!
        let quadrantWidth = frame.width/Double(AltitudeRepresentableViewModel.MAX_VALUES_SIZE)
        
        for i in 1..<AltitudeRepresentableViewModel.MAX_VALUES_SIZE {
            context.setStrokeColor(gray: 0.80, alpha: 0.30)
            context.setLineDash(phase: 0, lengths: [4,2])
            context.beginPath()
            context.move(to: CGPoint(x: Double(i)*quadrantWidth, y: frame.minY))
            context.addLine(to: CGPoint(x: Double(i)*quadrantWidth, y: frame.maxY))
            context.strokePath()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let quadrantWidth = frame.width/Double(AltitudeRepresentableViewModel.MAX_VALUES_SIZE)
        let frameMaxY = frame.maxY - "00:00".attributed([.font(UIFont.monospacedSystemFont(ofSize: 6, weight: .light))]).size().height - 4
        let frameMinY = frame.minY + "9999".attributed([.font(UIFont.monospacedSystemFont(ofSize: 8, weight: .light))]).size().height + 4
        let graphHeight = frameMaxY - frameMinY
        //let graphHeight = frameMaxY -
        
        let timestamps = values.map { $0.timestamp }
        let values = values.map { $0.location }
        
        context.setStrokeColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.setFillColor(CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        context.beginPath()
        context.move(to: CGPoint(x: frame.minX, y: frame.minY + frame.height/2))
        context.addLine(to: CGPoint(x: frame.maxX, y: frame.minY + frame.height/2))
        context.addLine(to: CGPoint(x: frame.minX, y: frame.minY))
        
        context.setFillColor(CGColor(red: 0, green: 1, blue: 0, alpha: 1))
        
        // Want to draw vertically..
        let gradientStart = CGPoint(x: frame.minX, y: frame.minY)
        let gradientEnd = CGPoint(x: frame.minX, y: frameMaxY)
        
        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill([CGRect(origin: CGPoint(x: frame.minX, y: frame.minY), size: CGSize(width: frame.width, height: frame.height))])
        
        self.drawColumnDividers()
        
        context.setLineDash(phase: 0, lengths: [])
        
        for i in 0..<values.count {
            let time = Date(timeIntervalSince1970: Double(timestamps[i]))
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
        var maxY = ((values.max() ?? 1).padRound())
        // TODO: Round down
        var minY = (values.min() ?? 1)
        
        // Adjust max/min from +-1 median? Improve view with insufficient range.
        if (values.max()! - values.min()!) < 3 {
            maxY = values.max()! + 1
            minY = values.min()! - 1
        }
        
        // Scales from 0 to 1
        let scaler: (Int) -> Double = { val in
            let slope = 1.0/Double(maxY - minY)
            
            // Apply 1-res at the front to deal with coordinate system (yes, it would cancel)
            return 1.0 - (Double((val-maxY))*slope + 1.0)
        }
        
        print("Scaled: \(values.map({scaler($0)}))")
        
        // Start at bottom-left corner?
        context.beginPath()
        context.setStrokeColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))
        context.setFillColor(CGColor(red: 1.0, green: 0, blue: 0, alpha: 1.0))
        context.setLineWidth(2)
        context.setLineJoin(CGLineJoin.bevel)
        for i in 0..<values.count {
            // y in local coords
            let y = frameMinY + graphHeight*(scaler(values[i]))
            // x in local coords
            let x = frame.minX + (Double(i)*quadrantWidth + quadrantWidth/2)
            
            // Draw the downward connector line
            if i > 0 {
                let prevY = frameMinY + graphHeight*(scaler(values[i-1]))
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
                let firstY = frameMinY + graphHeight*(scaler(values[0]))
                //context.move(to: CGPoint(x: frame.minX + Double(values.count)*quadrantWidth, y: y))
                context.addLine(to: CGPoint(x: frame.minX + Double(values.count)*quadrantWidth, y: frameMaxY))
                // Move back to origin
                // Bottom connecting line -- make opaque
                /*
                context.addLine(to: CGPoint(x: frame.minX, y: frameMaxY))
                context.addLine(to: CGPoint(x: frame.minX, y: firstY))
                 */
            }
            
            // Draw value text above
            let valueString = "\(values[i])"
                .attributed([
                    .foregroundColor(UIColor.white),
                    .font(UIFont.monospacedSystemFont(ofSize: 8, weight: .light))
                ])
            
            let valuePadding = (quadrantWidth - valueString.size().width)/2
            let valueStartX = frame.minX + (Double(i)*quadrantWidth) + valuePadding
            let valueStartY = y-valueString.size().height-2
            
            valueString.draw(at: CGPoint(x: valueStartX, y: valueStartY))
        }
        
        if let existingPath = context.path?.copy() {
            // Draw the incomplete path
            context.setStrokeColor(CGColor(red: 0.4, green: 0.0, blue: 1.0, alpha: 1.0))
            context.drawPath(using: .stroke)
            context.addPath(existingPath)
            
            if values.count == AltitudeRepresentableViewModel.MAX_VALUES_SIZE {
                let firstY = frameMinY + graphHeight*(scaler(values[0]))
                context.setStrokeColor(CGColor(red: 0.4, green: 0.0, blue: 1.0, alpha: 0.0))
                context.move(to: CGPoint(x: frame.minX + Double(values.count)*quadrantWidth, y: frameMaxY))
                context.addLine(to: CGPoint(x: frame.minX, y: frameMaxY))
                context.addLine(to: CGPoint(x: frame.minX, y: firstY))
            }
            
            context.clip()
            context.drawLinearGradient(AltitudeView.graphGradient, start: gradientStart, end: gradientEnd, options: CGGradientDrawingOptions.drawsAfterEndLocation)
        }
    }
}

extension Int {
    func padRound() -> Int {
        let places: Double = Double(Swift.max("\(self)".count-2, 1))
        return Int(ceil((Double(self) / pow(10, places))) * pow(10, places))
    }
}

class AltitudeRepresentableViewModel: ObservableObject {
    static let MAX_VALUES_SIZE = 5
    @Published var values: [Altitude] = []
    
    func pushValue(_ value: Altitude) {
        if values.count == AltitudeRepresentableViewModel.MAX_VALUES_SIZE {
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

extension View {
    func frame(width: CGFloat, aspectRatio: CGFloat) -> some View {
        self.frame(width: width, height: width/aspectRatio)
    }
}

struct Altitude {
    let location: Int
    let timestamp: Int
}

struct AltitudePreviewView: View {
    @StateObject var model: AltitudeRepresentableViewModel = AltitudeRepresentableViewModel()
    
    var body: some View {
        VStack {
            AltitudeRepresentableView(model: model)
                .frame(width: 300, aspectRatio: 3/2)
                .onAppear {
                    (0..<AltitudeRepresentableViewModel.MAX_VALUES_SIZE).forEach { _ in
                        let altitude = Int.random(in: 20...100)
                        model.pushValue(Altitude(location: altitude, timestamp: Int(Date().timeIntervalSince1970)))
                    }
                }
            Button("Push data") {
                let altitude = Int.random(in: 20...100)
                model.pushValue(Altitude(location: altitude, timestamp: Int(Date().timeIntervalSince1970)))
            }
        }
    }
}

struct AltitudeView_Previews: PreviewProvider {
    static var previews: some View {
        AltitudePreviewView()
    }
}
