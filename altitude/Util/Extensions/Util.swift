//
//  Util.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/5/23.
//

import Foundation
import SwiftUI

extension Array where Element == Int {
    func cumsum() -> Array {
        var sums: [Element] = []
        
        for val in self {
            sums.append((sums.last ?? 0) + val)
        }
        
        return sums
    }
}

func binomial(p: Double = 0.5) -> Int {
    assert(p >= 0.0)
    assert(p <= 1.0)
    
    return (Double.random(in: 0...1.0) <= p) ? 1 : 0
}

func binomialWalk(k: Int = 1, p: Double = 0.5) -> [Int] {
    assert(p >= 0.0)
    assert(p <= 1.0)
    
    return (0..<k).map { _ in
        binomial(p: p)
    }
    .cumsum()
}

extension CGPoint {
    func rotate(_ angle: Angle) -> CGPoint {
        // TODO: breaks after 90 deg? (two solutions given sqrt)
        let R = self.distance()
        // Compute existing angle of point
        let T = atan(self.y/self.x) + angle.radians
        // Assume angle is 0
        
        let xp = pow(pow(R,2.0)/(1 + pow(tan(T),2.0)), 1/2)
        let yp = pow((pow(R,2.0) - pow(xp, 2.0)), 1/2)
        
        return CGPoint(x: xp, y: yp)
    }
    
    func distance() -> CGFloat {
        return sqrt(pow(self.x, 2) + pow(self.y, 2))
    }
}

extension Double {
    func measurement<UnitType: Unit>(_ type: UnitType) -> Measurement<UnitType> {
        Measurement(value: self, unit: type.self)
    }
}
