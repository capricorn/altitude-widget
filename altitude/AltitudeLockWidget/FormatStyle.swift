//
//  FormatStyle.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import Foundation

private extension TimeInterval {
    var days: Int {
        Int(floor(self / (24*60*60)))
    }
}

extension AltitudeLockWidget {
    struct CompactWidgetDateFormatStyle: FormatStyle {
        typealias FormatInput = Date
        typealias FormatOutput = String
        
        static let style = Self()
        
        func format(_ value: Date) -> String {
            let elapsedTime = Date.now.timeIntervalSince1970 - value.timeIntervalSince1970
            let formatter = DateFormatter()
            
            if elapsedTime.days < 1 {
                // Present the time of the previous reading
                // TODO: Handle 24 hr time setting
                formatter.amSymbol = "am"
                formatter.pmSymbol = "pm"
                formatter.dateFormat = "h:mm a"
            } else {
                // TODO: Use locale for this? Maybe it already does..?
                formatter.dateFormat = "M/dd"
            }
            
            return formatter.string(from: value)
        }
    }
    
    struct CompactWidgetTime: FormatStyle {
        typealias FormatInput = TimeInterval
        typealias FormatOutput = String
        
        static let style = Self()
        
        func format(_ value: TimeInterval) -> String {
            let formatter = DateComponentsFormatter()
            
            if value < 60*60 {
                formatter.unitsStyle = .short
                formatter.allowedUnits = [ .minute ]
                return formatter.string(from: value)!
            } else if value < 24*60*60 {
                formatter.unitsStyle = .full
                formatter.allowedUnits = [ .hour ]
                return formatter.string(from: value)!
            } else {
                formatter.unitsStyle = .short
                formatter.allowedUnits = [ .day ]
                return formatter.string(from: value)!
            }
        }
    }
}
