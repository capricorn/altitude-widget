//
//  SettingsView.swift
//  mtnmap
//
//  Created by Collin Palmer on 10/31/23.
//

import SwiftUI
import WidgetKit
import CoreLocation

// TODO: Produce mock in preview
protocol LocationServiceStatusProtocol: ObservableObject {
    associatedtype ObjectWillChangePublisher
    var status: CLAuthorizationStatus? { get }
}

class LocationServiceStatusDeniedMock: LocationServiceStatusProtocol {
    var status: CLAuthorizationStatus? {
        .denied
    }
}

class LocationServiceStatusOkayMock: LocationServiceStatusProtocol {
    var status: CLAuthorizationStatus? {
        .authorizedAlways
    }
}

class LocationServiceStatus: LocationServiceStatusProtocol {
    private let manager: CLLocationManager
    private let delegate: LocationDelegate!
    
    @Published var status: CLAuthorizationStatus? = nil
    
    class LocationDelegate: NSObject, CLLocationManagerDelegate {
        var callback: ((CLAuthorizationStatus) -> Void)? = nil
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            self.callback?(manager.authorizationStatus)
        }
    }
    
    init() {
        self.manager = CLLocationManager()
        self.delegate = LocationDelegate()
        
        self.delegate.callback = { authStatus in
            self.status = authStatus
        }
        
        self.manager.delegate = self.delegate
    }
}

struct SettingsView<T: LocationServiceStatusProtocol>: View {
    typealias AltitudeUnit = UserDefaults.Settings.AltitudeUnit
    typealias TimeNotation = UserDefaults.Settings.TimeNotation

    @AppStorage(AltitudeUnit.defaultKey) private var unitSelection: AltitudeUnit = .feet
    @AppStorage(TimeNotation.defaultKey) private var timeSelection: TimeNotation = .hour12
    
    @EnvironmentObject var gpsStatus: T
    
    // TODO: Make optional instead
    var locationAvailable: Bool {
        guard let status = gpsStatus.status else {
            return false
        }
        
        return (status == .authorizedAlways || status == .authorizedWhenInUse)
    }
    
    var settingsListView: some View {
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
            
            if locationAvailable == false {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text("Location is disabled.")
                    Spacer()
                }
            }
        }       
    }
    
    var body: some View {
        ZStack {
            settingsListView
                .onChange(of: unitSelection) { _ in
                    // TODO: Reference from a single place
                    WidgetCenter.shared.reloadTimelines(ofKind: "com.goatfish.altitude")
                }
                .onAppear {
                    if gpsStatus.status != nil, locationAvailable == false {
                        // TODO: Request permissions
                        // TODO: Will this also account for widget permissions?
                        CLLocationManager().requestWhenInUseAuthorization()
                    }
                }
            VStack {
                Spacer()
                Image(systemName: "mountain.2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 16)
                    .foregroundColor(.gray)
                    .opacity(0.10)
            }
        }
    }
}

#Preview {
    SettingsView<LocationServiceStatusDeniedMock>()
        .environmentObject(LocationServiceStatusDeniedMock())
        .defaultAppStorage(.init(suiteName: "settings-preview-defaults")!)
}

#Preview {
    SettingsView<LocationServiceStatusOkayMock>()
        .environmentObject(LocationServiceStatusOkayMock())
        .defaultAppStorage(.init(suiteName: "settings-preview-defaults")!)
}
