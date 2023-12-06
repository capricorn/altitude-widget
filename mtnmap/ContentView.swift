//
//  ContentView.swift
//  mtnmap
//
//  Created by Collin Palmer on 3/11/23.
//

import SwiftUI
import CoreMotion
import CoreLocation
import Combine
import WidgetKit

struct ContentView: View {
    var body: some View {
        SettingsView<LocationServiceStatus>()
            .environmentObject(LocationServiceStatus())
            .defaultAppStorage(.init(suiteName: UserDefaults.Settings.appGroupId)!)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
