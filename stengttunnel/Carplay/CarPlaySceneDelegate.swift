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
    let enabled: Bool
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
    
    func updateRoads() {
        self.listItems.filter({ $0.enabled }).forEach { listItem in
            self.updateListItem(item: listItem.item, favorite: listItem.favorite) {
                // All good
            }
        }
    }
    
    func drawScreen() {
        timer.invalidate()
        
        var timerInterval = 60.0
        #if DEBUG
        timerInterval = 10.0
        #endif
        
        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { _ in
            print("Updating list")
            self.updateRoads()
        })

        
        let favoriteList = CPListTemplate(title: "Stengt tunnel", sections: [
            CPListSection(items: [])
        ])
            
        var sections = [CPListSection]()
        let enabledItems = self.listItems.filter({ $0.enabled }).map { $0.item }
        let disabledItems = self.listItems.filter({ $0.enabled == false }).map { $0.item }
        
        if disabledItems.isEmpty {
            sections = [
                CPListSection(items:enabledItems)
            ]
        } else {
            sections = [
                CPListSection(items: enabledItems),
                CPListSection(items: disabledItems, header: String(localized: "Buy Stengt tunnel+"), sectionIndexTitle: "")
            ]
        }
        favoriteList.updateSections(sections)
        favoriteList.tabSystemItem = .favorites
        
        updateRoads()

        interfaceController?.setRootTemplate(favoriteList, animated: true, completion: { _, _ in
            // Do nothing
        })
    }
    
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")
        loadStore {
            self.listItems = []
            
            for (index, favorite) in self.store.favorites.enumerated() {
                let active = self.storeManager.subscriptionActive || index < 2
                let item = self.getListItemFromFavorite(favorite: favorite, enabled: active)
                self.listItems.append(ListItem(favorite: favorite, item: item, enabled: active))
            }
            
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
    
    func getListItemFromFavorite(favorite: Favorite, enabled: Bool = false) -> CPListItem {
        let item = CPListItem(text: favorite.roadName, detailText: String(localized: "is ..."), image: TrafficLightView(color: .yellow).render(blurred: !enabled))
        if enabled {
            item.handler = { item, completion in
                print("Clicked \(favorite.roadName)")
                self.updateListItem(item: item as! CPListItem, favorite: favorite) {
                    do {usleep(500000)}
                    completion()
                }
            }
        } else {
            item.isEnabled = false
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
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        print("CarPlay launched")
    }
}
