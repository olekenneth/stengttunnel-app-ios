//
//  ContentView.swift
//  Stengt tunnel watch Watch App
//
//  Created by Ole-Kenneth on 30/08/2024.
//

import SwiftUI

struct ContentView: View {
    @State var lastUpdate = Date.now
    @StateObject private var store = FavoriteStore()
    var favorites: [Road] {
        return store.favorites.map { favorite in
            return Road(roadName: favorite.roadName, urlFriendly: favorite.urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0))
        }
    }

    
    var body: some View {
        ScrollView {
            if $store.favorites.isEmpty {
                RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), lastUpdated: $lastUpdate)
            } else {
                ForEach(Array(favorites.enumerated()), id: \.element.urlFriendly) { index, favorite in
                    RoadView(road: favorite, lastUpdated: $lastUpdate)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
