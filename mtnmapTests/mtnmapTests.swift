//
//  mtnmapTests.swift
//  mtnmapTests
//
//  Created by Collin Palmer on 3/11/23.
//

import XCTest
@testable import mtnmap

final class mtnmapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // TODO: Integer solutions? Rounding troubles
    /*
    func testPointRotation() throws {
        let point = CGPoint(x: 1, y: 1)
        let rotatedPoint = point.rotate(.degrees(45))
        
        XCTAssert(rotatedPoint.equalTo(CGPoint(x: 0, y: sqrt(1))), "Rotation: \(rotatedPoint)")
    }
    */
}
