//
//  mtnmapTests.swift
//  mtnmapTests
//
//  Created by Collin Palmer on 3/11/23.
//

import XCTest
import CoreLocation
import WidgetKit
@testable import mtnmap
@testable import altitudeWidget

final class mtnmapTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        UserDefaults().removePersistentDomain(forName: self.name)
        self.defaults = UserDefaults(suiteName: self.name)
    }

    override func tearDownWithError() throws {
        self.defaults = nil
    }

    func testAltitudeCodable() throws {
        let fixedDate = Date(timeIntervalSince1970: 1698960233)
        let entry = CompactAltitudeEntry(date: fixedDate, altitude: 1000)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = try encoder.encode(entry)
        
        XCTAssert(json.string == #"{"altitude":1000,"date":"2023-11-02T21:23:53Z"}"#, json.string ?? "n/a")
    }
    
    /// Verify the cache is hit when multiple timeline update requests are made
    /// This simulates how a widget with multiple instances works -- each instance will make
    /// a request for (depending on the widget) the same data.
    func testWidgetProviderCacheUpdate() throws {
        class MockGPS: GPS {
            private var returnImmediately = false
            
            override func location(_ callback: @escaping (Result<CLLocation, AuthorizationError>) -> Void) {
                let location: CLLocation = CLLocation(
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    altitude: 500.0,
                    horizontalAccuracy: 0.0,
                    verticalAccuracy: 0.0,
                    timestamp: Date()
                )
                
                if returnImmediately {
                    let location = CLLocation(
                        coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                        altitude: 1000.0,
                        horizontalAccuracy: 0.0,
                        verticalAccuracy: 0.0,
                        timestamp: Date()
                    )
                    callback(.success(location))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                        callback(.success(location))
                    }
                    
                    returnImmediately = true
                }
            }
        }
        
        let mockGPS = MockGPS()
        let provider = AltitudeLockWidgetProvider<MockGPS>(gps: mockGPS)
        let expectation1 = XCTestExpectation(description: "Timeline refresh 1 request completed.")
        let expectation2 = XCTestExpectation(description: "Timeline refresh 2 request completed.")
        let expectation3 = XCTestExpectation(description: "Timeline refresh 3 request completed.")
        
        print("\(self.name) Submitting task 1")
        provider.updateTimeline(defaults: self.defaults) { container in
            print("\(self.name) Fulfilled e1: \(Date())")
            XCTAssert(self.defaults.currentAltitude?.altitude == 1640)
            XCTAssert(self.defaults.lastAltitude == nil)
            expectation1.fulfill()
        }
        
        print("\(self.name) Submitting task 2")
        // Below verifies that the cache is hit even with multiple timeline calls
        provider.updateTimeline(defaults: self.defaults) { container in
            print("\(self.name) Fulfilled e2: \(Date())")
            XCTAssert(self.defaults.currentAltitude?.altitude == 1640)
            XCTAssert(self.defaults.lastAltitude == nil)
            expectation2.fulfill()
        }
        
        print("\(self.name) Submitting task 3")
        provider.updateTimeline(defaults: self.defaults) { container in
            print("\(self.name) Fulfilled e3: \(Date())")
            XCTAssert(self.defaults.currentAltitude?.altitude == 1640)
            XCTAssert(self.defaults.lastAltitude == nil)
            expectation3.fulfill()
        }
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5)
    }
    
    /// Verify that when the cache is stale that the previous and current cache values are updated; that is
    /// (prev: nil, curr: foo) -> (prev: foo, curr: bar)
    func testWidgetProviderStaleCache() throws {
        class MockGPS: GPS {
            override func location(_ callback: @escaping (Result<CLLocation, AuthorizationError>) -> Void) {
                let location: CLLocation = CLLocation(
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                    altitude: 500.0,
                    horizontalAccuracy: 0.0,
                    verticalAccuracy: 0.0,
                    timestamp: Date()
                )
                
                callback(.success(location))
            }
        }
        
        let gps = MockGPS()
        let provider = AltitudeLockWidgetProvider<MockGPS>(gps: gps)
        let expectation = XCTestExpectation()
        
        // First: set the cache
        provider.updateTimeline(defaults: self.defaults) { _ in
            print("First update")
            XCTAssert(self.defaults.currentAltitude != nil)
            XCTAssert(self.defaults.lastAltitude == nil)
        }
        
        // This should be a cache hit -- defaults shouldn't change
        provider.updateTimeline(defaults: self.defaults) { _ in
            print("Second update")
            XCTAssert(self.defaults.currentAltitude != nil)
            XCTAssert(self.defaults.lastAltitude == nil)
        }
        
        // Rule: if current cache is set and an update occurs after cache expiration, set it
        provider.updateTimeline(currentDate: Date.now + 10.min, defaults: self.defaults) { _ in
            print("Update -- cache expired")
            XCTAssert(self.defaults.currentAltitude?.altitude == 1640)
            XCTAssert(self.defaults.lastAltitude?.altitude == 1640)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
    }
}
