//
//  Util.swift
//  altitudeExtension
//
//  Created by Collin Palmer on 9/5/23.
//

import Foundation

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
