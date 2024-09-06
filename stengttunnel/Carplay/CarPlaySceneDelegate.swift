//
//  CarPlaySceneDelegate.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 06/09/2024.
//

import Foundation
import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate, UISceneDelegate {
    private var store = FavoriteStore()
    private var storeManager = StoreManager.shared

    private var interfaceController: CPInterfaceController?
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("sceneWillResignActive")
    }

    
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")

        let favoriteList = CPListTemplate(title: "Stengt tunnel", sections: [
            CPListSection(items: [
            ])
        ])

        loadStore {
            favoriteList.updateSections([
                
                CPListSection(items: self.store.favorites.prefix(2).map({ favorite in
                    self.fetchRoad(favorite)
                })),
                
                CPListSection(items: self.store.favorites.suffix(from: 2).map({ favorite in
                    self.getListItemFromRoad(favorite: favorite, status: Status(statusMessage: "", status: .yellow))
                }), header: String(localized: "Buy Stengt tunnel+"), sectionIndexTitle: "")
            ])
        }
        
        favoriteList.tabSystemItem = .favorites

        // let closestList = CPListTemplate(title: "Nærmeste", sections: [
        //     CPListSection(items: [
        //         CPListItem(text: "Operatunnelen", detailText: "ser ut til å være åpen", image: TrafficLightView(color: .green).render()),
        //         CPListItem(text: "Vaterlandstunnelen", detailText: "ser ut til å være stengt", image: TrafficLightView(color: .red).render()),
        //         CPListItem(text: "Oslofjordtunnelen", detailText: "ser ut til å være åpen", image: TrafficLightView(color: .green).render()),
        //     ])
        // ])
        //
        // closestList.tabImage = UIImage(systemName: "map.fill")

        
        // let tabBar = CPTabBarTemplate(templates: [favoriteList, closestList])
        interfaceController?.setRootTemplate(favoriteList, animated: true, completion: { _,_ in
            // Do nothing
        })

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
    
    func getListItemFromRoad(favorite: Favorite, status: Status) -> CPListItem {
        let item = CPListItem(text: favorite.roadName, detailText: String(localized: "is ..."), image: TrafficLightView(color: .yellow).render(blurred: true))
        item.handler = { item, completion in
            print("Clicked \(favorite.roadName)")
            
            completion()
        }

        return item
    }

    func fetchRoad(_ favorite: Favorite) -> CPListItem {
        let item = CPListItem(text: favorite.urlFriendly.localizedCapitalized, detailText: String(localized: "is ..."), image: TrafficLightView(color: .yellow).render())
        item.handler = { item, completion in
            print("Clicked \(favorite.roadName)")
            
            completion()
        }

        Dataloader.shared.loadRoad(road: favorite.urlFriendly) { status in
            if let status {
                item.setText(favorite.roadName)
                item.setDetailText(status.statusMessage.replacingOccurrences(of: favorite.roadName + " ", with: ""))
                item.setImage(TrafficLightView(color: status.status).render())
            }
        }
        return item
    }
        
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        print("CarPlay launched")
    }
}
