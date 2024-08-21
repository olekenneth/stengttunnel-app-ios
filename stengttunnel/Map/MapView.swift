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
    @State private var selectedMarker: String?
    @State private var selectedRoad: Road?
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
            Map(initialPosition: .userLocation(fallback: .camera(.init(centerCoordinate:  CLLocationCoordinate2D(latitude:59.66902, longitude: 10.62224), distance: 10000))), selection: $selectedMarker) {

                ForEach(markers) { road in
                    // MarkerView(road: road).view().tag(1)
                    Marker(road.roadName, coordinate: CLLocationCoordinate2D(latitude: road.gps.lat, longitude: road.gps.lon)).tag(road.urlFriendly)
                }
                UserAnnotation()
            }
            .safeAreaInset(edge: .bottom) {
                if let road = selectedRoad {
                    RoadView(road:road, lastUpdated: $lastUpdated)
                }
            }
            .onChange(of: selectedMarker, { oldValue, newValue in
                if let urlFriendly = selectedMarker {
                    selectedRoad = Road(roadName: urlFriendly.localizedCapitalized, urlFriendly: urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0))
                    lastUpdated = Date.now
                } else {
                    selectedRoad = nil
                    lastUpdated = Date.now
                }
            })
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
    
    var body: some View {
        MapView(roads: roads)
    }
}

#Preview {
    return Preview()
}
