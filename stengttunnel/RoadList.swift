//
//  RoadList.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 08/08/2024.
//

import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds


private func saveStore(store: FavoriteStore) {
    DispatchQueue.main.async {
        print("Saving store")
        store.save(favorites: store.favorites)
    }
}

struct SearchResults {
    let favorites: [Favorite]
    let roads: [Road]
}

enum SortOptions: String, CaseIterable, Identifiable {
    case distance, name
    var id: Self { self }
}

struct RoadList: View {
    var storeManager = StoreManager.shared
    
    @StateObject private var store = FavoriteStore()
    @State private var roads = [Road]()
    @State private var searchText = ""
    @Environment(\.scenePhase) private var scenePhase
    @State private var isSearching = false
    @State private var showSearch = false
    @State private var lastRefreshed = Date.now
    @State private var showSettings = false
    @State private var sorted: SortOptions = .name
    @StateObject var locationManager = LocationManager.shared
    
    
    var favorites: [Road] {
        return store.favorites.map { favorite in
            return Road(roadName: favorite.roadName, urlFriendly: favorite.urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0))
        }
    }
    
    var width: CGFloat = UIScreen.main.bounds.width
    
    var size: CGSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width).size
    }
    
    var body: some View {
        TabView {
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
                        VStack() {
                            ForEach(favorites, id: \.self.urlFriendly) { favorite in
                                RoadView(road: favorite, lastUpdated: $lastRefreshed)
                                if !storeManager.subscriptionActive {
                                    BannerView().frame(height: size.height)
                                    PlusTeaser(showSettings: $showSettings).frame(height: size.height)
                                }
                            }
                        }
                        .background(Color("lightGray"))
                    }
                }.padding(0)
                    .refreshable {
                        runSearch()
                        lastRefreshed = Date.now
                    }
                    .searchableOnce(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Choose roads", isPresented: $showSearch)
                    .searchSuggestions {
                        if locationManager.location != nil {
                            HStack {
                                Text("Sort by")
                                Spacer()
                                Picker("Sort by", selection: $sorted) {
                                    Text("Name").tag(SortOptions.name)
                                    HStack {
                                        Text("Distance")
                                        Image(systemName: "location")
                                    }.tag(SortOptions.distance)
                                }
                            }
                            .listRowSeparator(.hidden)
                        } else {
                            HStack(alignment: .top) {
                                Image(systemName: "location.circle")
                                Text("Sort by distance")
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                sorted = .distance
                                locationManager.updateLocation()
                            }
                        }
                        if !searchResults.favorites.isEmpty {
                            Section {
                                ForEach(searchResults.favorites) { favorite in
                                    let road = Road(roadName: favorite.roadName, urlFriendly: favorite.urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0), distance: 0)
                                    SearchResultItem(road: road, isFavorite: true) {
                                        store.toggle(road: favorite)
                                        store.save(favorites: store.favorites)
                                    }
                                }
                            } header: {
                                Text("Favorites")
                            }
                        }
                        Section {
                            ForEach(searchResults.roads) { road in
                                SearchResultItem(road: road, isFavorite: false) {
                                    if !storeManager.subscriptionActive && store.favorites.count > 1 {
                                        showSearch = false
                                        searchText = ""
                                        showSettings = true
                                        
                                        return
                                    }
                                    store.toggle(road: Favorite(roadName: road.roadName, urlFriendly: road.urlFriendly))
                                    store.save(favorites: store.favorites)
                                }
                            }
                            if searchResults.roads.isEmpty {
                                HStack {
                                    Text(searchResults.roads.isEmpty && !searchText.isEmpty ? "No result" : "Loading roads. Please wait...")
                                        .font(.headline)
                                    Spacer()
                                }
                            }
                        } header: {
                            Text("Roads")
                        }
                    }
                    .toolbarTitleDisplayMode(.inlineLarge)
                    .navigationTitle(Text("Stengt tunnel"))
                    .sheet(isPresented: $showSettings) {
                        NavigationView {
                            ScrollView {
                                SubscriptionView()
                            }
                            .navigationTitle("Settings")
                            .navigationBarTitleDisplayMode(.large)
                            .toolbar {
                                ToolbarItem {
                                    Button("Done") {
                                        showSettings = false
                                    }
                                }
                            }
                        }
                    }
                
            }
            .onChange(of: scenePhase) { oldPhase, phase in
                if phase == .inactive {
                    saveStore(store: store)
                }
                if oldPhase == .inactive && phase == .active {
                    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
                    runSearch()
                }
            }
            .onAppear() {
                runSearch()
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
            .tabItem { Label("Roads", systemImage: "list.dash") }
            
            MapView(roads: roads).tabItem { Label("Map", systemImage: "map") }
            
            SubscriptionView().tabItem { Label("User", systemImage: "person.circle") }
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
    
    var searchResults: SearchResults {
        var allRoads = roads
        
        if let _ = locationManager.location {
            allRoads = locationManager.sortLocationsByDistance(locations: allRoads)
        }
        
        if sorted == .name {
            allRoads = allRoads.sorted(by: { r1, r2 in
                return r1.roadName < r2.roadName
            })
        }
        
        let allFavorties = store.favorites.map { favorite in
            allRoads.removeAll { road in
                road.urlFriendly == favorite.urlFriendly
            }
            return favorite
        }
        
        if searchText.isEmpty {
            return SearchResults(favorites: allFavorties, roads: allRoads)
        } else {
            return SearchResults(favorites: allFavorties.filter {$0.roadName.localizedCaseInsensitiveContains(searchText) }, roads: allRoads.filter { $0.roadName.localizedCaseInsensitiveContains(searchText) })
        }
    }
}

#Preview {
    RoadList()
}
