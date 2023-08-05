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
    let url: URL
}

private func saveStore(store: FavoriteStore) {
    Task {
        do {
            try await store.save(favorites: store.favorites)
        } catch {
            fatalError(error.localizedDescription)
        }
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
            .searchableOnce(text: $searchText, prompt: "Velg tunnel(er)")
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
                        } else {
                            store.favorites.insert(Favorite(roadName: road.roadName, urlFriendly: road.urlFriendly), at: 0)
                            
                        }
                    }
                }
            }
            .onAppear(perform: runSearch)
            .onSubmit(of: .search, runSearch)
        }
    }
    
    func runSearch() {
        Task {
            guard let url = URL(string: "https://stengttunnel.no/roads.json") else { return }

            let (data, _) = try await URLSession.shared.data(from: url)
            roads = try JSONDecoder().decode([Road].self, from: data)
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
