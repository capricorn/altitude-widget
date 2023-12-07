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
        defaults = UserDefaults(suiteName: self.name)
        defaults.removePersistentDomain(forName: self.name)
    }

    override func tearDownWithError() throws {
        defaults = nil
    }

    func testAltitudeCodable() throws {
        let fixedDate = Date(timeIntervalSince1970: 1698960233)
        let entry = CompactAltitudeEntry(date: fixedDate, altitude: 1000)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = try encoder.encode(entry)
        
        XCTAssert(json.string == #"{"altitude":1000,"date":"2023-11-02T21:23:53Z"}"#, json.string ?? "n/a")
    }
    
    /**
     Verify the cache state updates in the following manner:
     Given the cache variables (prev, curr)
     (prev: nil, curr: nil) -> (prev: nil, curr: foo)
     (prev: nil, curr: foo) -> (prev: foo, curr: bar)
     (prev: foo, curr: bar) -> (prev: bar, curr: baz)
     */
    func testWidgetProviderCacheUpdate() throws {
        XCTAssert(self.defaults.currentAltitude == nil)
        XCTAssert(self.defaults.lastAltitude == nil)
        
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
        // TODO: Allow injection of cache for tests
        let provider = AltitudeLockWidgetProvider<MockGPS>(gps: mockGPS)
        let expectation1 = XCTestExpectation(description: "Timeline refresh 1 request completed.")
        let expectation2 = XCTestExpectation(description: "Timeline refresh 2 request completed.")
        let expectation3 = XCTestExpectation(description: "Timeline refresh 3 request completed.")
        
        // TODO: Verify cache values
        // TODO: Attempt to verify cache timestamps
        // TODO: **Verify cache hit within 5 minutes vs outside of that**
        
        print("Updating timeline: \(Date())")
        provider.updateTimeline(defaults: self.defaults) { container in
            print("Fulfilled e1: \(Date())")
            expectation1.fulfill()
            XCTAssert(provider.cache.currentAltitude?.altitude == 1640, "\(provider.cache.currentAltitude?.altitude)")
            XCTAssert(provider.cache.lastAltitude == nil)
        }
        
        // Below verifies that the cache is hit even with multiple timeline calls
        provider.updateTimeline(defaults: self.defaults) { container in
            print("Fulfilled e2: \(Date())")
            expectation2.fulfill()
            XCTAssert(provider.cache.currentAltitude?.altitude == 1640, "\(provider.cache.currentAltitude?.altitude)")
            XCTAssert(provider.cache.lastAltitude == nil)
        }
        
        provider.updateTimeline(defaults: self.defaults) { container in
            print("Fulfilled e3: \(Date())")
            expectation3.fulfill()
            XCTAssert(provider.cache.currentAltitude?.altitude == 1640, "\(provider.cache.currentAltitude?.altitude)")
            XCTAssert(provider.cache.lastAltitude == nil)
        }
        
        wait(for: [expectation1, expectation2, expectation3], timeout: 5)
    }
    
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
        Task {
            provider.updateTimeline { _ in
                print("First update")
                XCTAssert(provider.cache.currentAltitude != nil)
                XCTAssert(provider.cache.lastAltitude == nil)
            }
        }
        
        Task {
            provider.updateTimeline { _ in
                print("Second update")
                XCTAssert(provider.cache.currentAltitude != nil)
                XCTAssert(provider.cache.lastAltitude == nil)
            }
        }
        
        Task {
            // Rule: if current cache is set and an update occurs 5 minutes later, set it
            provider.updateTimeline(currentDate: Date.now + 10.min) { _ in
                print("Update -- cache expired")
                expectation.fulfill()
            }
        }
        
        Task {
            // Update after cache expiration -- should be ignored (ie hits cache)
            provider.updateTimeline(currentDate: Date.now + 11.min) { _ in
                print("Final update")
                // TODO: Expectation
            }
        }
        
        wait(for: [expectation], timeout: 3)
        
        // TODO: Check dates as well?
        XCTAssert(provider.cache.currentAltitude?.altitude == 1640, "cache: \(provider.cache.currentAltitude?.altitude)")
        XCTAssert(provider.cache.lastAltitude?.altitude == 1640)
    }
}
