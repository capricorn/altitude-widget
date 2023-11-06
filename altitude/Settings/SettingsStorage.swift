//
//  SettingsStorage.swift
//  mtnmap
//
//  Created by Collin Palmer on 10/31/23.
//

import Foundation

extension UserDefaults {
    var currentAccuracy: Double? {
        get {
            return Settings.defaults.double(forKey: Settings.currentAltitudeAccuracyKey)
        }
        set {
            Settings.defaults.set(newValue, forKey: UserDefaults.Settings.currentAltitudeAccuracyKey)
        }
    }
    
    var lastAltitude: CompactAltitudeEntry? {
        get {
            if let rawDefault = Settings.defaults.string(forKey: Settings.lastAltitudeReadingKey)?.data(using: .utf8) {
                return try? JSONDecoder().decode(CompactAltitudeEntry.self, from: rawDefault)
            }
            
            return nil
        }
        set {
            Settings.defaults.set(newValue?.rawValue, forKey: UserDefaults.Settings.lastAltitudeReadingKey)
        }
    }
    
    var currentAltitude: CompactAltitudeEntry? {
        get {
            if let rawDefault = Settings.defaults.string(forKey: Settings.currentAltitudeReadingKey)?.data(using: .utf8) {
                return try? JSONDecoder().decode(CompactAltitudeEntry.self, from: rawDefault)
            }
            
            return nil
        }
        set {
            Settings.defaults.set(newValue?.rawValue, forKey: UserDefaults.Settings.currentAltitudeReadingKey)
        }
    }
    
    var displayAccuracy: Bool {
        get {
            Settings.defaults.bool(forKey: Settings.displayAccuracyKey)
        }
        set {
            Settings.defaults.set(newValue, forKey: Settings.displayAccuracyKey)
        }
    }
    
    enum Settings {
        static let appGroupId = "group.com.goatfish.altitudegroup"
        static let lastAltitudeReadingKey = "last_altitude_reading"
        static let currentAltitudeReadingKey = "current_altitude_reading"
        static let displayAccuracyKey = "display_accuracy"
        static let currentAltitudeAccuracyKey = "current_altitude_std_dev"
        
        static let defaults = UserDefaults(suiteName: appGroupId)!
        
        enum AltitudeUnit: String, CaseIterable, Identifiable, RawRepresentable {
            case feet
            case meters
            
            var label: String {
                switch self {
                case .feet: "Feet"
                case .meters: "Meters"
                }
            }
            
            var compactLabel: String {
                switch self {
                case .feet:
                    "′"
                case .meters:
                    "m"
                }
            }
            
            var id: Self {
                self
            }
            
            static let defaultKey = "altitude_unit"
        }
        
        enum TimeNotation: String, CaseIterable, Identifiable, RawRepresentable {
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
    }
}
