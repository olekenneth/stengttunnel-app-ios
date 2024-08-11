//
//  LocationManager.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 11/08/2024.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private var locationManager = CLLocationManager()
    
    @Published var location: CLLocation? = nil
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func sortLocationsByDistance(locations: [Road]) -> [Road] {
        return locations.sorted { loc1, loc2 in
            let location1 = CLLocation(latitude: loc1.gps.lat, longitude: loc1.gps.lon)
            let location2 = CLLocation(latitude: loc2.gps.lat, longitude: loc2.gps.lon)
            
            // Compare distances from userLocation
            return location1.distance(from: self.location!) < location2.distance(from: self.location!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.location = newLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
