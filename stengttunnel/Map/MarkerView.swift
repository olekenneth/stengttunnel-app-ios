//
//  MarkerView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 14/08/2024.
//

import SwiftUI
import MapKit

struct MarkerView {
    var road: Road
        
    let marker = MKMapItem()
    
    func view() -> Marker<Text> {
        Marker(road.roadName, coordinate: CLLocationCoordinate2D(latitude: road.gps.lat, longitude: road.gps.lon))
    }
}
