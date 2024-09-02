//
//  FavoritesStore.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 05/08/2023.
//
import SwiftUI
import WatchConnectivity

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
        
        if WCSession.isSupported() { //makes sure it's not an iPad or iPod
            let watchSession = WCSession.default
            watchSession.delegate = self
            watchSession.activate()
            if watchSession.isPaired && watchSession.isWatchAppInstalled {
                do {
                    try watchSession.updateApplicationContext(["favorites": self.favorites])
                } catch let error as NSError {
                    print(error.description)
                }
            }
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
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func isEqual(_ object: Any?) -> Bool {
        self.isEqual(object)
    }
    
    var hash: Int {
        self.hash
    }
    
    var superclass: AnyClass? {
        self.superclass
    }
    
    func `self`() -> Self {
        self.self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        self.perform(aSelector)
    }
    
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        self.perform(aSelector, with: object)
    }
    
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        self.perform(aSelector, with: object1, with: object2)
    }
    
    func isProxy() -> Bool {
        self.isProxy()
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        self.isKind(of: aClass)
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        self.isMember(of: aClass)
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        self.conforms(to: aProtocol)
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        self.responds(to: aSelector)
    }
    
    var description: String {
        return self.favorites.map { fav in
            return fav.urlFriendly
        }.joined(separator: ", ")
    }
}
