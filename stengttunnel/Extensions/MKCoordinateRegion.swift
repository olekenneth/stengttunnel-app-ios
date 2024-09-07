//
//  MKCoordinateRegion.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 14/08/2024.
//

import Foundation
import MapKit

extension MKCoordinateRegion {
    var mapRect: MKMapRect {
        // Calculate longitudinal and latitudinal distances in map points
        let latitudeDelta = span.latitudeDelta
        let longitudeDelta = span.longitudeDelta

        let topLeftCoord = CLLocationCoordinate2D(latitude: center.latitude + latitudeDelta / 2,
                                                  longitude: center.longitude - longitudeDelta / 2)
        let bottomRightCoord = CLLocationCoordinate2D(latitude: center.latitude - latitudeDelta / 2,
                                                      longitude: center.longitude + longitudeDelta / 2)

        let topLeftMapPoint = MKMapPoint(topLeftCoord)
        let bottomRightMapPoint = MKMapPoint(bottomRightCoord)

        return MKMapRect(x: topLeftMapPoint.x,
                         y: topLeftMapPoint.y,
                         width: fabs(bottomRightMapPoint.x - topLeftMapPoint.x),
                         height: fabs(bottomRightMapPoint.y - topLeftMapPoint.y))
    }
}
