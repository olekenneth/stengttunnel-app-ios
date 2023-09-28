//
//  FavoritesStore.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 05/08/2023.
//
import SwiftUI

struct Favorite: Identifiable, Codable {
    var id = UUID()
    var roadName: String
    var urlFriendly: String
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
        var favorites = try await task.value
        
        if favorites.isEmpty {
            favorites.append(Favorite(roadName: "Hammersborgtunnelen", urlFriendly: "hammersborgtunnelen"))
            favorites.append(Favorite(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen"))
        }
        
        self.favorites = favorites
    }
    
    func save(favorites: [Favorite]) {
        Task {
            let data = try JSONEncoder().encode(favorites)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
    }
}
