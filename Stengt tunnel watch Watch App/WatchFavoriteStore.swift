//
//  WatchFavoriteStore.swift
//  Stengt tunnel Watch App
//
//  Created by Ole-Kenneth on 09/09/2024.
//

import SwiftUI
import WatchConnectivity

class WatchFavoriteStore: NSObject, ObservableObject, WCSessionDelegate {
    @Published var favorites: [Favorite] = [Favorite(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen")]
    
    var session: WCSession
    
    init(session: WCSession = WCSession.default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Got ctx", applicationContext)
        if let ctx = applicationContext["favorites"] {
            let favorites = ctx as! [String]
            self.favorites = favorites.map({ fav in
                Favorite(roadName: fav, urlFriendly: fav)
            })
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("got message", message)
            if (message["favorites"] != nil) {
                self.favorites = message["favorites"] as! [Favorite]
            }
        }
    }
}
