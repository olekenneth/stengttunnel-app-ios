//
//  Stengt_TunnelApp.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct Road: Identifiable, Codable {
    var id: String { urlFriendly }
    let roadName: String
    let urlFriendly: String
    var url: URL { URL(string: "https://api.stengttunnel.no/" + urlFriendly + "/v2")! }
    let messages: [Message]
    let gps: GPS
}

private func saveStore(store: FavoriteStore) {
    DispatchQueue.main.async {
        store.save(favorites: store.favorites)
    }
}

@main
struct Stengt_TunnelApp: App {
    @StateObject private var store = FavoriteStore()
    @State private var roads = [Road]()
    @State private var searchText = ""
    @State private var favorites = Set<String>()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach($store.favorites) { $favorite in
                            RoadView(urlFriendly: favorite.urlFriendly)
                        }
                    }
                    .background(Color("lightGray"))
                    .task {
                        do {
                            try await store.load()
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    saveStore(store: store)
                }
            }
            .searchableOnce(text: $searchText, prompt: "Choose roads")
            .searchSuggestions {
                Button("Save", role: .cancel) {
                    // dismissSearch()
                    saveStore(store: store)
                }
                ForEach(searchResults) { road in
                    HStack {
                        Text(road.roadName)
                            .font(.headline)
                        Spacer()
                        if (store.favorites.contains(where: { favorite in
                            favorite.urlFriendly == road.urlFriendly
                        })) {
                            Image(systemName: "checkmark")
                        } else {
                            Image(systemName: "plus")
                        }
                    }
                    .onTapGesture {
                        let entry = store.favorites.firstIndex(where: { favorite in
                            favorite.urlFriendly == road.urlFriendly
                        })
                        if (entry != nil) {
                            store.favorites.remove(at: entry!)
                            if store.favorites.isEmpty {
                                store.favorites.insert(Favorite(roadName: "Ingen tunnel valgt", urlFriendly: "no-road"), at: 0)
                            }
                        } else {
                            store.favorites.insert(Favorite(roadName: road.roadName, urlFriendly: road.urlFriendly), at: 0)
                            
                        }
                    }
                }
//                List {
//                    ForEach(searchResults) { road in
//                        NavigationLink {
//                            Text(road.roadName)
//                                .font(.headline)
//                            Spacer()
//                            if (store.favorites.contains(where: { favorite in
//                                favorite.urlFriendly == road.urlFriendly
//                            })) {
//                                Image(systemName: "checkmark")
//                            } else {
//                                Image(systemName: "plus")
//                            }
//
//                        } label: {
//                            Text(road.roadName)
//                        }
//                        //                     .onTapGesture {
//                        //                         let entry = store.favorites.firstIndex(where: { favorite in
//                        //                             favorite.urlFriendly == road.urlFriendly
//                        //                         })
//                        //                         if (entry != nil) {
//                        //                             store.favorites.remove(at: entry!)
//                        //                         } else {
//                        //                             store.favorites.insert(Favorite(roadName: road.roadName, urlFriendly:  road.urlFriendly), at: 0)
//                        //
//                        //                         }
//                    }
//                }
            }
            .onAppear(perform: runSearch)
            .onSubmit(of: .search, runSearch)
        }
    }
    
    func runSearch() {
        Task {
            Dataloader.shared.loadRoads { result in
                // print(result.values)
                roads = result.map({ (key: String, value: Road) in
                    return value
                }).sorted(by: { roadA, roadB  in
                    return roadA.roadName < roadB.roadName
                })
                // print(roads)
            }
        }
    }

    var searchResults: [Road] {
        if searchText.isEmpty {
            return roads
        } else {
            return roads.filter { $0.roadName.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
