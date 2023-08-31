//
//  AltitudeGraphProvider.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 8/30/23.
//

import Foundation
import WidgetKit

struct AltitudeGraphProvider: TimelineProvider {
    typealias Entry = Altitude
    
    func placeholder(in context: Context) -> Altitude {
        return Altitude(location: 10, timestamp: 10)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Altitude) -> Void) {
        // TODO: Pass in current state..?
        let altitude = Altitude(location: 50, timestamp: Int(Date().timeIntervalSince1970))
        completion(altitude)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Altitude>) -> Void) {
        // TODO: Generate / assign random value for now
    }
}
