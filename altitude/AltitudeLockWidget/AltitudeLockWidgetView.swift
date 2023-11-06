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

private extension FormatStyle where Self == AltitudeLockWidget.CompactWidgetDateFormatStyle {
    static var compactWidgetDate: AltitudeLockWidget.CompactWidgetDateFormatStyle { self.style }
}

private extension FormatStyle where Self == AltitudeLockWidget.CompactWidgetTime {
    static var compactWidgetTime: AltitudeLockWidget.CompactWidgetTime { self.style }
}

struct altitudeEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    @AppStorage(UserDefaults.Settings.AltitudeUnit.defaultKey)
    private var defaultUnit: UserDefaults.Settings.AltitudeUnit = .feet
    
    @AppStorage(UserDefaults.Settings.TimeNotation.defaultKey) 
    private var defaultTime: UserDefaults.Settings.TimeNotation = .hour12
    
    @AppStorage(UserDefaults.Settings.displayAccuracyKey)
    private var displayAccuracy: Bool = false
    
    @AppStorage(UserDefaults.Settings.displayAccuracyKey)
    private var currentAccuracy: Double?
    
    private var prevAltitude: CompactAltitudeEntry? {
        container.prevEntry
    }
    
    private var unitLabel: String {
        defaultUnit.compactLabel
    }
    
    var container: AltitudeEntryContainer
    
    private var altitude: CompactAltitudeEntry {
        container.currentEntry
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
        return "\(sign)\(signPad)\(abs(delta))\(unitLabel) in \(prevTime.formatted(.compactWidgetTime))"
    }
    
    var accuracyLabel: String {
        if let currentAccuracy, displayAccuracy {
            // 2 std dev (~95%)
            return "±\(Int(currentAccuracy*2.0))"
        }
        
        return ""
    }
    
    var body: some View {
        if widgetFamily == .accessoryInline {
            Text("\(altitude.altitude)\(accuracyLabel)\(unitLabel)")
        } else {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Image(systemName: "mountain.2.circle")
                    Text("\(altitude.altitude)\(accuracyLabel)\(unitLabel)")
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
}
