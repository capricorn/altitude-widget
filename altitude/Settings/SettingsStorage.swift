//
//  SettingsStorage.swift
//  mtnmap
//
//  Created by Collin Palmer on 10/31/23.
//

import Foundation

extension UserDefaults {
    enum Settings {
        enum AltitudeUnit: String, CaseIterable, Identifiable {
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
                    "ft"
                case .meters:
                    "m"
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
    }
}
