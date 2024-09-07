//
//  CarPlaySceneDelegate.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 06/09/2024.
//

import Foundation
import CarPlay

struct ListItem {
    let favorite: Favorite
    let item: CPListItem
}

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, UISceneDelegate {
    private var store = FavoriteStore()
    private var storeManager = StoreManager.shared
    private var timer = Timer()
    private var listItems = [ListItem]()
    
    private var interfaceController: CPInterfaceController?
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")
        timer.invalidate()
    }
    
    func drawScreen() {
        timer.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            print("Updating list")
            self.listItems.forEach { listItem in
                self.updateListItem(item: listItem.item, favorite: listItem.favorite) {
                    // All good
                }
            }
        })

        
        let favoriteList = CPListTemplate(title: "Stengt tunnel", sections: [
            CPListSection(items: [])
        ])
            
        var sections = [CPListSection]()
        let items = self.listItems.map({ $0.item })
        
        if self.storeManager.subscriptionActive {
            sections = [
                CPListSection(items:items)
            ]
        } else {
            sections = [
                CPListSection(items: Array(items.prefix(2))),
                
                CPListSection(items: Array(items.suffix(from: 2)), header: String(localized: "Buy Stengt tunnel+"), sectionIndexTitle: "")
            ]
        }
        favoriteList.updateSections(sections)
        
        favoriteList.tabSystemItem = .favorites

        interfaceController?.setRootTemplate(favoriteList, animated: true, completion: { _, _ in
            // Do nothing
        })
    }
    
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")
        loadStore {
            self.listItems = []
            
            self.store.favorites.forEach({ favorite in
                self.listItems.append(ListItem(favorite: favorite, item: self.fetchRoad(favorite)))
            })
            
            self.drawScreen()
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground")
    }
    
    
    func loadStore(_ completion: @escaping () -> Void) {
        Task {
            do {
                try await store.load()
                completion()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func getListItemFromFavorite(favorite: Favorite, blurred: Bool = true) -> CPListItem {
        let item = CPListItem(text: favorite.roadName, detailText: String(localized: "is ..."), image: TrafficLightView(color: .yellow).render(blurred: blurred))
        item.handler = { item, completion in
            print("Disabled click on \(favorite.roadName)")
            
            completion()
        }
        
        return item
    }
    
    func updateListItem(item: CPListItem, favorite: Favorite, callback: @escaping () -> Void) {
        Dataloader.shared.loadRoad(road: favorite.urlFriendly) { status in
            if let status {
                item.setText(favorite.roadName)
                item.setDetailText(status.statusMessage.replacingOccurrences(of: favorite.roadName + " ", with: ""))
                item.setImage(TrafficLightView(color: status.status).render())
            }

            callback()
        }
    }
    
    func fetchRoad(_ favorite: Favorite) -> CPListItem {
        let item = getListItemFromFavorite(favorite: favorite, blurred: false)
        item.handler = { item, completion in
            print("Clicked \(favorite.roadName)")
            self.updateListItem(item: item as! CPListItem, favorite: favorite) {
                do {usleep(500000)}
                completion()
            }
        }
        
        updateListItem(item: item, favorite: favorite) {
            // Do nothing
        }
        
        return item
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        print("CarPlay launched")
    }
}
