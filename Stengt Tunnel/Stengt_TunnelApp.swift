//
//  Stengt_TunnelApp.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

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
    @State private var lastRefreshed = Date.now
    var favorites: [Road] {
        return store.favorites.map { favorite in
            return Road(roadName: favorite.roadName, urlFriendly: favorite.urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0))
        }
    }

    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScrollView {
                    if $store.favorites.isEmpty {
                        HStack {
                            Spacer()
                            VStack {
                                Text("No favorites")
                                    .font(.headline)
                                Text("Click to add")
                                    .font(.subheadline)
                            }
                            Spacer()
                        }.padding()
                            .onTapGesture(perform: {
                                showSearch = true
                            })
                    } else {
                        VStack(alignment: .leading) {
                            ForEach(favorites) { favorite in
                                RoadView(road: favorite, lastUpdated: $lastRefreshed)
                            }
                        }
                        .background(Color("lightGray"))
                    }
                }
            }
            .refreshable {
                runSearch()
                print(lastRefreshed)
                lastRefreshed = Date.now
                print(lastRefreshed)
            }
            .onChange(of: scenePhase) { oldPhase, phase in
                if phase == .inactive {
                    saveStore(store: store)
                }
                if oldPhase == .inactive && phase == .active {
                    runSearch()
                }
            }
            .onAppear() {
                Task {
                    do {
                        try await store.load()
                        if store.favorites.isEmpty {
                            showSearch = true
                        }
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .searchableOnce(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Choose roads", isPresented: $showSearch)
            .searchSuggestions {
                if searchResults.isEmpty {
                    HStack {
                        Text(searchResults.isEmpty && !searchText.isEmpty ? "No result" : "Loading roads. Please wait...")
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
        Task {
            isSearching = true
            Dataloader.shared.loadRoads { result in
                isSearching = false
                guard result == nil else {
                    return roads = result!.sorted(by: { roadA, roadB  in
                        return roadA.roadName < roadB.roadName
                    })
                }
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
