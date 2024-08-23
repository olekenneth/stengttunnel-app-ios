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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyReduced
    }
    
    func updateLocation() {
        print("Updating new location")
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func sortLocationsByDistance(locations: [Road]) -> [Road] {
        guard self.location != nil else { return locations }
        
        return locations.map { road in
            let location = CLLocation(latitude: road.gps.lat, longitude: road.gps.lon)
            return Road(roadName: road.roadName, urlFriendly: road.urlFriendly, messages: road.messages, gps: road.gps, distance: Double((self.location?.distance(from: location))!))
        }
        .sorted { $0.distance! < $1.distance! }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.location = newLocation
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
