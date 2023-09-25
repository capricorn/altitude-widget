//
//  AltitudeLockWidgetView.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/25/23.
//

import SwiftUI

private extension Int {
    var signLabel: String {
        if self > 0 {
            return "↗"
        } else if self < 0 {
            return "↘"
        }
        
        // Negative case is already included when a number is converted to a string.
        return ""
    }
}

private struct CompactWidgetDateFormatStyle: FormatStyle {
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

private extension TimeInterval {
    var days: Int {
        Int(floor(self / (24*60*60)))
    }
}

private extension FormatStyle where Self == CompactWidgetDateFormatStyle {
    static var compactWidgetDate: CompactWidgetDateFormatStyle { self.style }
}

private extension FormatStyle where Self == CompactWidgetTime {
    static var compactWidgetTime: CompactWidgetTime { self.style }
}

private struct CompactWidgetTime: FormatStyle {
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

struct altitudeEntryView : View {
    //var entry: Provider.Entry
    //var prevEntry: Provider.Entry?
    var container: AltitudeEntryContainer
    
    private var altitude: CompactAltitudeEntry {
        container.currentEntry
    }
    
    private var prevAltitude: CompactAltitudeEntry? {
        container.prevEntry
    }
    
    private var altitudeDeltaLabel: String? {
        guard let prevAltitude else {
            return nil
        }
        
        let delta = altitude.altitude - prevAltitude.altitude
        let sign = delta.signLabel
        let prevTime = altitude.date.timeIntervalSince1970 - prevAltitude.date.timeIntervalSince1970
        // If delta is zero, no sign is present; ergo, no padding.
        let signPad = (delta == 0) ? "" : " "
        
        // TODO: Use settings measurement
        return "\(sign)\(signPad)\(abs(delta)) ft in \(prevTime.formatted(.compactWidgetTime))"
    }
    

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 4) {
                Image(systemName: "mountain.2.circle")
                Text("\(altitude.altitude) ft")
            }
            
            Group {
                if let altitudeDeltaLabel {
                    Text(altitudeDeltaLabel)
                }
                
                // TODO: Use 'on' for entries occurring >24 hr ago
                (Text("at ") + Text(altitude.date.formatted(.compactWidgetDate)))
                    .foregroundColor(Color.gray)
            }
            .font(.caption)
            .fontWeight(.light)
            .truncationMode(.tail)
        }
    }
}
