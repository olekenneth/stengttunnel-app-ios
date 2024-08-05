//
//  Stengt_TunnelApp.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
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

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      GADMobileAds.sharedInstance().start(completionHandler: nil)
      GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "dd2a8297212c345481b88d737efcb859" ]

    return true
  }
}

@main
struct Stengt_TunnelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var store = FavoriteStore()
    @State private var roads = [Road]()
    @State private var searchText = ""
    @Environment(\.scenePhase) private var scenePhase
    @State private var isSearching = false
    @State private var showSearch = false
    @State private var lastRefreshed = Date.now
    @State private var showSettings = false
    var favorites: [Road] {
        return store.favorites.map { favorite in
            return Road(roadName: favorite.roadName, urlFriendly: favorite.urlFriendly, messages: [], gps: GPS(lat: 0, lon: 0))
        }
    }
    
    var width: CGFloat = UIScreen.main.bounds.width

    var size: CGSize {
        return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width).size
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
                        VStack() {
                            ForEach(favorites, id: \.self.urlFriendly) { favorite in
                                RoadView(road: favorite, lastUpdated: $lastRefreshed)
                                BannerView().frame(height: size.height)
                            }
                        }.padding(.bottom)
                            .background(Color("lightGray"))
                    }
                }
                .navigationTitle(Text("Stengt tunnel"))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        // Button("Settings", systemImage: "person.circle", role: .destructive) {
                        //     showSettings = !showSettings
                        // }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    Button("Close", role: .destructive) {
                        showSettings = false
                    }
                    Text("This is the settings page")
                }
                .toolbarTitleDisplayMode(.inlineLarge)

            }
            .refreshable {
                runSearch()
                lastRefreshed = Date.now
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
