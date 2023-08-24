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
    
    override func draw(_ rect: CGRect) {
        //super.draw(rect)
        // TODO
        let context = UIGraphicsGetCurrentContext()!
        let quadrantWidth = frame.width/Double(AltitudeRepresentableViewModel.MAX_VALUES_SIZE)
        //let startPoint = CGPoint(x: frame.minX, y: frame.minY)
        
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
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            "\(components.hour!):\(components.minute!)"
                .attributed([
                    .foregroundColor(UIColor.cyan),
                    .font(UIFont.monospacedSystemFont(ofSize: 8, weight: .light))
                ])
                .draw(at: CGPoint(x: Double(i)*quadrantWidth, y: frame.minY))
        }
        
        // Should scale according to this; need to handle negatives
        // Can take min as zero, max as..? Round up to nearest multiple..? (given places)
        //let values = [50, 234, 100, 75]
        // Normalize [0,1] and multiply against frame height (use maxY for now)
        // TODO: Handle negatives -- abs ok?
        var maxY = (values.max()!)
        let minY = values.min()!
        
        /*
        if (maxY % 100) > 0 {
            maxY = 100*(Int(maxY)/100 + 1)
            print(maxY)
        }
         */
        
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
            
            // Draw value text above
            "\(values[i])"
                .attributed([
                    .foregroundColor(UIColor.cyan),
                    .font(UIFont.monospacedSystemFont(ofSize: 8, weight: .light))
                ])
                // TODO: Compute proper font height
                .draw(at: CGPoint(x: frame.minX + (Double(i)*quadrantWidth+quadrantWidth/2), y: y-10))
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
