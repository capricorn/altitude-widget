//
//  SettingsView.swift
//  mtnmap
//
//  Created by Collin Palmer on 10/31/23.
//

import SwiftUI

struct SettingsView: View {
    typealias AltitudeUnit = UserDefaults.Settings.AltitudeUnit
    typealias TimeNotation = UserDefaults.Settings.TimeNotation

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
