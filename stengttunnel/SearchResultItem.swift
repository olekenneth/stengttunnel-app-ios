//
//  SearchResultItem.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 12/08/2024.
//

import SwiftUI

struct SearchResultItem: View {
    var road: Road
    var isFavorite: Bool
    var tapGesture: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(road.roadName)
                    .font(.headline)
                if road.distance ?? -1 > 0  {
                    Text("\(Int(road.distance?.convert(from: .meters, to: .kilometers) ?? 0)) km")
                        .font(.caption)
                }
            }
            Spacer()
            if (isFavorite) {
                Image(systemName: "checkmark")
            } else {
                Image(systemName: "plus")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            tapGesture()
        }
    }
}

#Preview {
    List {
        SearchResultItem(road: Road(roadName: "Bomlafjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), isFavorite: true) {
            print("Hei")
        }
        SearchResultItem(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), isFavorite: true) {
            print("Hei")
        }
        SearchResultItem(road: Road(roadName: "Masefjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0), distance: 321.0), isFavorite: false) {
            print("Hei")
        }
        SearchResultItem(road: Road(roadName: "Masefjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0), distance: 123.0), isFavorite: false) {
            print("Hei")
        }
        SearchResultItem(road: Road(roadName: "Masefjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), isFavorite: false) {
            print("Hei")
        }
    }.listStyle(.plain)
}
