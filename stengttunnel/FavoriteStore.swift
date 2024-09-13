//
//  FavoritesStore.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 05/08/2023.
//
import SwiftUI
import WatchConnectivity

@MainActor
class FavoriteStore: NSObject, ObservableObject {
    @Published var favorites: [Favorite] = []
    private var watchSession: WCSession?
    
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
        
        print("Loaded favorites", self.favorites)
        if WCSession.isSupported() { // makes sure it's not an iPad or iPod
            print("WCSession is supported")
            watchSession = WCSession.default
            watchSession?.delegate = self
            watchSession?.activate()
        }

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
        sendToWatch()
    }
    
    func sendToWatch() {
        if let session = watchSession {
            if session.isPaired && session.isWatchAppInstalled {
                DispatchQueue.main.async {
                    print(self.favorites)
                    do {
                        let favorites = self.favorites.map({ $0.urlFriendly }) as [String]
                        
                        try session.updateApplicationContext(["favorites": favorites])
                    } catch let error as NSError {
                        print("WKError", error.description)
                    }
                }
            }
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

extension FavoriteStore: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
            print("Trying to update watch", self.favorites)
            sendToWatch()
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
}
