//
//  SettingsView.swift
//  mtnmap
//
//  Created by Collin Palmer on 10/31/23.
//

import SwiftUI

struct SettingsView: View {
    // TODO: Move elsewhere?
    enum AltitudeUnit: String, CaseIterable, Identifiable {
        case feet
        case meters
        
        var label: String {
            switch self {
            case .feet: "Feet"
            case .meters: "Meters"
            }
        }
        
        var id: Self {
            self
        }
        
        static let defaultKey = "altitude_unit"
    }
    
    enum TimeNotation: String, CaseIterable, Identifiable {
        case hour12
        case hour24
        
        var label: String {
            switch self {
            case .hour12:
                "24-hour"
            case .hour24:
                "12-hour"
            }
        }
        
        var id: Self {
            self
        }
        
        static let defaultKey = "time_notation"
    }
    
    @AppStorage(AltitudeUnit.defaultKey) private var unitSelection: AltitudeUnit?
    @AppStorage(TimeNotation.defaultKey) private var timeSelection: TimeNotation?
    
    var body: some View {
        List {
            // TODO: Possibly drop?
            Section("Settings") {
                Picker("Units", selection: $unitSelection) {
                    ForEach(AltitudeUnit.allCases) {
                        Text($0.label).tag($0)
                    }
                }
                
                Picker("Clock", selection: $timeSelection) {
                    ForEach(TimeNotation.allCases) {
                        Text($0.label).tag($0)
                    }
                }
            }
        }
        Text("Test: \((timeSelection ?? .hour12).label)")
    }
}

#Preview {
    SettingsView()
        .defaultAppStorage(.init(suiteName: "settings-preview-defaults")!)
}
