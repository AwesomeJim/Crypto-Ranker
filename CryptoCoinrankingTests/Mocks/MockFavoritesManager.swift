//
//  MockFavoritesManager.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 09/11/2025.
//

import Foundation
@testable import CryptoCoinranking

class MockFavoritesManager: FavoritesManagerProtocol {
    private var favorites = Set<String>()
    
    func addFavorite(uuid: String) {
        favorites.insert(uuid)
        // We can optionally test for this notification, but mocking it is simpler
        postFavoritesDidChangeNotification()
    }
    
    func removeFavorite(uuid: String) {
        favorites.remove(uuid)
        postFavoritesDidChangeNotification()
    }
    
    func isFavorite(uuid: String) -> Bool {
        return favorites.contains(uuid)
    }
    
    func getFavoriteUUIDs() -> Set<String> {
        return favorites
    }
    
    func postFavoritesDidChangeNotification() {
        
    }
}
