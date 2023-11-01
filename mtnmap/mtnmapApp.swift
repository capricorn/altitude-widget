//
//  mtnmapApp.swift
//  mtnmap
//
//  Created by Collin Palmer on 3/11/23.
//

import SwiftUI

@main
struct mtnmapApp: App {
    var body: some Scene {
        WindowGroup {
            SettingsView()
                .defaultAppStorage(.init(suiteName: UserDefaults.Settings.appGroupId)!)
        }
    }
}
