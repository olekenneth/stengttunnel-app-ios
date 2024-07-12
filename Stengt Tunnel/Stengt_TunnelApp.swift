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
        print("Saving store")
        store.save(favorites: store.favorites)
    }
}

@main
struct Stengt_TunnelApp: App {
    @StateObject private var store = FavoriteStore()
    @State private var roads = [Road]()
    @State private var searchText = ""
    @Environment(\.scenePhase) private var scenePhase
    @State private var isSearching = false
    @State private var showSearch = false
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScrollView {
                    if $store.favorites.isEmpty {
                        HStack {
                            Spacer()
                            VStack {
                                Text("Ingen favoritter")
                                    .font(.headline)
                                Text("Klikk for å legge til")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }.padding()
                            .onTapGesture(perform: {
                                print("CLICKING ")
                                showSearch = true
                            })
                    } else {
                        VStack(alignment: .leading) {
                            ForEach($store.favorites) { $favorite in
                                RoadView(urlFriendly: favorite.urlFriendly)
                            }
                        }
                        .background(Color("lightGray"))
                    }
                }
            }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive {
                    saveStore(store: store)
                }
            }
            .onAppear() {
                Task {
                    do {
                        print("Loading favorites store")
                        try await store.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
                if store.favorites.isEmpty {
                    showSearch = true
                }
            }
            .searchableOnce(text: $searchText, prompt: "Choose roads", isPresented: $showSearch)
            .searchSuggestions {
                if searchResults.isEmpty {
                    HStack {
                        Text(searchResults.isEmpty && !searchText.isEmpty ? "No result found" : "Loading roads. Please wait...")
                            .font(.headline)
                        Spacer()
                    }
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
                        store.toggle(road: Favorite(roadName: road.roadName, urlFriendly: road.urlFriendly))
                        store.save(favorites: store.favorites)
                    }
                }
            }
            .onAppear(perform: runSearch)
            .onSubmit(of: .search, runSearch)
        }
    }
    
    func runSearch() {
        if isSearching {
            return;
        }
        print("HELLO")
        Task {
            isSearching = true
            Dataloader.shared.loadRoads { result in
                // print(result.values)
                isSearching = false
                roads = result.sorted(by: { roadA, roadB  in
                    return roadA.roadName < roadB.roadName
                })
                
                // store.purge(roads: roads)
                // print(roads)
            }
        }
    }
    
    var searchResults: [Road] {
        if searchText.isEmpty {
            var allRoads = roads
            let allFavorties = store.favorites.map { favorite in
                allRoads.removeAll { road in
                    road.urlFriendly == favorite.urlFriendly
                }
                return Road(roadName: favorite.roadName, urlFriendly: favorite.urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0))
            }.sorted(by: { roadA, roadB  in
                return roadA.roadName < roadB.roadName
            })
            return allFavorties + allRoads
            
        } else {
            return roads.filter { $0.roadName.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
