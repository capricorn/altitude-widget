//
//  MockData.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/6/23.
//

import Foundation

extension StepGraphView {
    static let stepGraphEntry: AltitudeStepEntry = {
        let entryCount = 5
        let dates = (0..<entryCount).map { _ in
            Int.random(in: 5*60...30*60)
        }
        .cumsum()
        .map { offset in
            Date().addingTimeInterval(TimeInterval(offset))
        }
        
        let values = binomialWalk(k: entryCount, p: 0.5).map { $0 * 100 }
        
        let altitudes = zip(dates, values).map { time, altitude in
            AltitudeStepEntry.Altitude(value: altitude, time: time)
        }
        
        return AltitudeStepEntry(altitudes: altitudes)
    }()
}
