//
//  FavoritesViewModel.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import Foundation
internal import Combine

final class FavoritesViewModel {
    
    // MARK: - Dependencies & State
    private let networkService: NetworkServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    
    // Closure the ViewController will set to update its UI
    var onUpdate: (() -> Void)?
    
    // The source of truth for the FavoritesViewController
    private(set) var favoriteCoins: [Coin] = [] {
        didSet {
            onUpdate?()
        }
    }
    
    @Published var appError: AppError?
    
    
    // MARK: - Initialization
    
    init(networkService: NetworkServiceProtocol, favoritesManager: FavoritesManagerProtocol) {
        self.networkService = networkService
        self.favoritesManager = favoritesManager
        
        // Start observing favorite changes immediately
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Data Fetching and Filtering
    
    @MainActor
    func fetchFavoriteCoins() async {
        // 1. Get the list of favorited UUIDs
        let favoriteUUIDs = favoritesManager.getFavoriteUUIDs()
        
        guard !favoriteUUIDs.isEmpty else {
            favoriteCoins = []
            return
        }
        
        // 2. Fetch the full list of coins (to filter from)
        // For this test, we fetch the top 100 and filter locally.
        do {
            // We assume the top 100 contains all user favorites.
            let response = try await networkService.fetchCoins(offset: 0, limit: 100)
            
            // 3. Filter the full list to only include favorites
            favoriteCoins = response.data?.coins.filter { coin in
                favoriteUUIDs.contains(coin.uuid)
            } ??    []
        } catch {
            print("Failed to fetch and filter favorite coins: \(error.localizedDescription)")
            self.appError = AppError(title: "An Error Occurred", message: error.localizedDescription)
        }
    }
    
    // MARK: - Favorites Logic
    
    /// Toggles the favorite status of a coin based on its UUID.
    func toggleFavoriteStatus(for coin: Coin) {
        if favoritesManager.isFavorite(uuid: coin.uuid) {
            favoritesManager.removeFavorite(uuid: coin.uuid)
        } else {
            favoritesManager.addFavorite(uuid: coin.uuid)
        }
    }
    
    func isFavorite(coin: Coin) -> Bool {
        return favoritesManager.isFavorite(uuid: coin.uuid)
    }
    
    // MARK: - Notification Handling
    
    private func setupNotifications() {
        // When a favorite changes on Screen 1, we refetch and update this screen.
        NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.fetchFavoriteCoins()
            }
        }
    }
}
