//
//  ContentView.swift
//  mtnmap
//
//  Created by Collin Palmer on 3/11/23.
//

import SwiftUI
import CoreMotion
import CoreLocation
import Combine

// TODO: Upgrade phone to iOS 16
// If recording is relative, that should work reasonably well.
// Goal: using relative accelerometer sampling, determine walking direction/distance
// (alongside barometer)
// With these 3 sensor, should be possible to create a 3d terrain map of hike.

// TODO: Understand computing direction given relative acc changes. (may require iphone orientation as well?)
// Idea: 'center' of iphone is translated in space. Use that to determine directional change?
// Note: timestamp is known in this case; approx 1s between sampling.
// Graph is acceleration over time (diff. graph for each component).
// Remember your integrals!
// Given acceleration at two points in time: can we determine distance? (Start with on axis only. Z is easiest.)

private extension CMAcceleration {
    static func -(lhs: CMAcceleration, rhs: CMAcceleration) -> CMAcceleration {
        CMAcceleration(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y,
            z: lhs.z - rhs.z
        )
    }
}

extension CMAcceleration: CustomStringConvertible {
    public var description: String {
        ["x: \(String(format: "%.02f", self.x * 9.8))",
         "y: \(String(format: "%.02f", self.x * 9.8))",
         "z: \(String(format: "%.02f", self.x * 9.8))"
        ].joined(separator: " ")
    }
}

// TODO: StringDescribable extension that converts relative acceleration to correct units. (m/s^2)

class AccelerationData {
    let motionManager = CMMotionManager()
    let motionQueue = OperationQueue()
    var prevAcceleration: CMAcceleration? = nil
    
    private let feedSubject = PassthroughSubject<CMAcceleration, Never>()
    var feed: AnyPublisher<CMAcceleration, Never> {
        feedSubject.eraseToAnyPublisher()
    }
    
    static let instance = AccelerationData()
    
    private init() {
        motionManager.accelerometerUpdateInterval = 1
        motionManager.startAccelerometerUpdates(to: motionQueue) { data, error in
            if let error {
                print("Error: \(error)")
                return
            }
            
            if let data, let prevAcceleration = self.prevAcceleration {
                //print("(x,y,z): \(data.acceleration)")
                //print("Acc Delta: \(data.acceleration - prevAcceleration)")
                self.feedSubject.send(data.acceleration - prevAcceleration)
            }
            
            self.prevAcceleration = data?.acceleration
            
//            DispatchQueue.main.async {
//                self.prevAcceleration.data = data?.acceleration
//            }
        }
    }
}

struct ContentView: View {
    let altitudeManager = CMAltimeter()
    let altitudeQueue = OperationQueue()
    
    
    //private let prevAcceleration: AccelerationData = AccelerationData()
    let acceleration = AccelerationData.instance
    let accelerationSubscriber: AnyCancellable?
    
    init() {
        // Can use relative altitiude if that seems more helpful -- probably is.
        altitudeManager.startAbsoluteAltitudeUpdates(to: altitudeQueue) { data, error in
            if let error {
                print("Error: \(error)")
                return
            }

            if let data {
                print("Altitude: \(data.altitude)")
            }
        }
        
        accelerationSubscriber = acceleration.feed.receive(on: RunLoop.main).sink { acc in
            print("\(acc)")
        }
        
    }
    
    @StateObject var model: AltitudeRepresentableViewModel = AltitudeRepresentableViewModel()
    
    let locationManager = CLLocationManager()
    let locationDelegate = LocationDelegate()
    
    var body: some View {
        
        //AltitudePreviewView()
        AltitudeRepresentableView(model: model)
            .frame(width: 500, height: 500)
            // TODO -- could pass `locationDelegate.publisher` here
            .onReceive(locationDelegate.locationPublisher) { location in
                model.pushValue(Int(location.altitude))
                print(model.values)
            }
            .onAppear {
                // Start location updates (according to authorization status)
                locationManager.delegate = locationDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                
                if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                    locationManager.startUpdatingLocation()
                } else {
                    print("Not authorized for location")
                    locationManager.requestAlwaysAuthorization()
                }
            }
            // TODO: Must be published to register?
            .onChange(of: locationManager.authorizationStatus) { newStatus in
                if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                    print("App authorized, start location updates.")
                    locationManager.startUpdatingLocation()
                }
            }
        /*
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
         */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
