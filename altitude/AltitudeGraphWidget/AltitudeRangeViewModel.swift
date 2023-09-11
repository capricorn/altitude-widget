//
//  AltitudeRangeViewModel.swift
//  mtnmap
//
//  Created by Collin Palmer on 9/11/23.
//

import Foundation
import SwiftUI

class AltitudeRangeViewModel: ObservableObject {
    @Published var max: CGFloat?
    @Published var min: CGFloat?
    @Published var current: CGFloat?
    
    private let missingLabel = "--"
    
    var maxLabel: String {
        guard let max else {
            return missingLabel
        }
        
        return Double(max).formatted(.number.precision(.fractionLength(0..<2)))
    }
    
    var minLabel: String {
        guard let min else {
            return missingLabel
        }
        
        return Double(min).formatted(.number.precision(.fractionLength(0..<2)))
    }
}
