//
//  MapView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 12/08/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    var roads: [Road]
    var locationManager = LocationManager.shared
    @State var selectedRoad: Road?
    @State private var lastUpdated = Date.now
    
    @State private var visibleRegion: MKMapRect?
    
    @State private var markers: [Road] = []

    func updateRoadInView() {
        markers.removeAll()
        for road in roads {
            let p = MKMapPoint(CLLocationCoordinate2D(latitude: road.gps.lat, longitude: road.gps.lon))
            if ((visibleRegion?.contains(p)) != nil) {
                markers.append(road)
            }
        }
    }
    
    
    var body: some View {
        VStack {
            Map(initialPosition: .userLocation(fallback: .camera(
                .init(centerCoordinate:  CLLocationCoordinate2D(latitude:59.66902, longitude: 10.62224), distance: 10000)
            ))) {
                ForEach(markers) { road in
                    MarkerView(road: road, selectedRoad: $selectedRoad).view()
                }
                UserAnnotation()
            }
            .mapControls {
                MapCompass()
                MapUserLocationButton()
            }
            .onMapCameraChange { context in
                visibleRegion = context.region.mapRect
                updateRoadInView()
            }
            .controlSize(.large)
        }.onAppear() {
            locationManager.updateLocation()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Preview: View {
    var roads = [
        Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 59.748611, lon: 10.615833)),
        Road(roadName: "E39", urlFriendly: "e39", messages: [], gps: GPS(lat: 58.969975, lon: 5.733107)),
    ]
    @State private var selectedRoad: Road?
    
    var body: some View {
        MapView(roads: roads, selectedRoad: selectedRoad)
    }
}

#Preview {
    return Preview()
}
