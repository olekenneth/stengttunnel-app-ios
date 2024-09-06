//
//  MapView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 12/08/2024.
//

import SwiftUI
import MapKit
import GoogleMobileAds

struct MapView: View {
    var roads: [Road]
    var locationManager = LocationManager.shared
    @State private var selectedMarker: String?
    @State private var selectedRoad: Road?
    @State private var lastUpdated = Date.now
    
    @State private var visibleRegion: MKMapRect?
    @State private var markers: [Road] = []

    @State private var scrollViewContentSize: CGSize = .zero
    
    func updateRoadInView() {
        markers.removeAll()
        for road in roads {
            let p = MKMapPoint(CLLocationCoordinate2D(latitude: road.gps.lat, longitude: road.gps.lon))
            if ((visibleRegion?.contains(p)) != nil) {
                markers.append(road)
            }
        }
    }
    
    var width: CGFloat = UIScreen.main.bounds.width
    
    var size: CGSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width).size
    }
        
    var body: some View {
        VStack {
            Map(initialPosition: .userLocation(fallback: .camera(.init(centerCoordinate:  CLLocationCoordinate2D(latitude:59.66902, longitude: 10.62224), distance: 10000))), selection: $selectedMarker) {
                ForEach(markers) { road in
                    MarkerView(road: road).view().tag(road.urlFriendly)
                }
                UserAnnotation()
            }
            .safeAreaInset(edge: .bottom) {
                if let road = selectedRoad {
                    ScrollView {
                        VStack {
                            BannerView().frame(width: scrollViewContentSize.width, height: size.height).border(.blue)
                            RoadView(road: road, lastUpdated: $lastUpdated)
                                .background(
                                    GeometryReader { geo -> Color in
                                        DispatchQueue.main.async {
                                            print(geo.size)
                                            scrollViewContentSize = geo.size
                                        }
                                        return Color.clear
                                    }
                                )
                        }
                    }
                    .frame(
                        maxHeight: min(scrollViewContentSize.height, UIScreen.main.bounds.height / 2)
                    )
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding(5)
                    .shadow(radius: 5)
                }

            }
            .onChange(of: selectedMarker, { oldValue, newValue in
                if let urlFriendly = newValue, let road = markers.first(where: { $0.urlFriendly == urlFriendly }) {
                    selectedRoad = road
                    lastUpdated = Date()
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
