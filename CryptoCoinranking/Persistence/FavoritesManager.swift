//
//  FavoritesManager.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation

// A simple protocol for better testability (though not essential for this lightweight class)
protocol FavoritesManagerProtocol {
    func isFavorite(uuid: String) -> Bool
    func addFavorite(uuid: String)
    func removeFavorite(uuid: String)
    func getFavoriteUUIDs() -> Set<String>
}

final class FavoritesManager: FavoritesManagerProtocol {
    
    // A shared instance to access the manager easily across the app
    static let shared = FavoritesManager()
    
    // The key used to store the Set in UserDefaults
    private let favoritesKey = "FavoriteCoinUUIDs"
    
    // Private initializer to enforce the Singleton pattern
    private init() {}
    
    /**
     * Retrieves the current set of favorite coin UUIDs from UserDefaults.
     * Defaults to an empty Set if no data is found.
     */
    private func retrieveFavorites() -> Set<String> {
        return UserDefaults.standard.stringArray(forKey: favoritesKey)
            .map { Set($0) } ?? Set<String>()
    }
    
    /**
     * Saves the updated set of favorite coin UUIDs back to UserDefaults.
     */
    private func saveFavorites(_ favorites: Set<String>) {
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
        
        // Post a notification so other views (like FavoritesScreen) can update immediately
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    // MARK: - Public Interface
    
    func isFavorite(uuid: String) -> Bool {
        return retrieveFavorites().contains(uuid)
    }
    
    func addFavorite(uuid: String) {
        var favorites = retrieveFavorites()
        favorites.insert(uuid)
        saveFavorites(favorites)
    }
    
    func removeFavorite(uuid: String) {
        var favorites = retrieveFavorites()
        favorites.remove(uuid)
        saveFavorites(favorites)
    }
    
    func getFavoriteUUIDs() -> Set<String> {
        return retrieveFavorites()
    }
}

// MARK: - Notification Extension
// This provides a clean way to notify the UI when the favorites list changes
extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}
