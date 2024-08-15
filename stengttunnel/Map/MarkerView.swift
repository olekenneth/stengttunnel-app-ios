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
    @Binding var selectedRoad: Road?
    @State var lastUpdate = Date.now
    @State private var showPopover = false
    
    var body: some View {
        VStack {
            VStack {
                // RoadView(road: road, lastUpdated: $lastUpdate)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.caption)
                    .foregroundColor(Color.white)
                    .offset(x: 0, y: -5)
            }
            .background(Color(.white))
            .cornerRadius(10)
            .opacity(showPopover ? 1 : 0)

            Image(systemName: "mappin.circle.fill")
            Button {
                showPopover.toggle()
                print("Helo from btn")
            } label: {
                Text(road.roadName)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedRoad = road
            print("Helo from tap gest")

        }
    }
    
    let marker = MKMapItem()
    
    
    func view() -> Marker<Text> {
        Marker(road.roadName, coordinate: CLLocationCoordinate2D(latitude: road.gps.lat, longitude: road.gps.lon))
    }
}
