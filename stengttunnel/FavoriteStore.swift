//
//  FavoritesStore.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 05/08/2023.
//
import SwiftUI

struct Favorite: Identifiable, Codable, Equatable {
    var id = UUID()
    var roadName: String
    var urlFriendly: String
    
    static func ==(lhs: Favorite, rhs: Favorite) -> Bool {
        return lhs.urlFriendly == rhs.urlFriendly
    }
}

@MainActor
class FavoriteStore: ObservableObject {
    @Published var favorites: [Favorite] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("favorites.data")
    }
    
    func load() async throws {
        let task = Task<[Favorite], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let yourFavorites = try JSONDecoder().decode([Favorite].self, from: data)
            return yourFavorites
        }
        self.favorites = try await task.value
    }
    
    func remove(road: Favorite) {
        self.favorites.removeAll { $0 == road }
    }
    
    func insert(road: Favorite) {
        self.favorites.insert(road, at: 0)
    }
    
    func toggle(road: Favorite) {
        let exists = self.favorites.contains { $0 == road}
        
        if exists {
            remove(road: road)
        } else {
            insert(road: road)
        }
    }
        
    func save(favorites: [Favorite]) {
        Task {
            let data = try JSONEncoder().encode(favorites)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
    }
}
