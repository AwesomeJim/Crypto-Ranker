//
//  CoinListViewModel.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation
final class CoinListViewModel {
    
    // MARK: - Dependencies & State
    
    private let networkService: NetworkServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    
    // Closure the ViewController will set to update its UI
    var onUpdate: () -> Void = {}
    
    // The source of truth for the CoinListViewController
    private(set) var currentCoins: [Coin] = [] {
        didSet {
            // Automatically notify the ViewController when coins are updated
            onUpdate()
        }
    }
    
    // Pagination State
    private let limit = 20
    private var offset = 0
    private var maxCoins = 100
    private var isFetching = false
    
    // Filtering State
    private var rawFetchedCoins: [Coin] = [] // Holds the full, unfiltered list of 100 coins
    private var currentFilter: CoinFilter = .marketCap(.descending)
    
    // MARK: - Initialization
    
    init(networkService: NetworkServiceProtocol, favoritesManager: FavoritesManagerProtocol) {
        self.networkService = networkService
        self.favoritesManager = favoritesManager
    }
    
    // MARK: - API Fetching Logic
    
    /// Fetches the next page of 20 coins, up to the maximum of 100.
    @MainActor
    func fetchNextPage() async {
        guard !isFetching, offset < maxCoins else { return }
        isFetching = true
        
        do {
            let response = try await networkService.fetchCoins(offset: offset, limit: limit)
            
            // Append new coins to the raw list
            rawFetchedCoins.append(contentsOf: response.data?.coins ?? []);
            
            // Update the offset for the next fetch
            offset += limit
            
            // Apply the current filter/sort order to the combined list
            applyFilter(currentFilter)
            
        } catch {
            logInfo("Failed to fetch coins: \(error.localizedDescription)")
            // In a real app, you'd communicate this error to the View
        }
        
        isFetching = false
    }
    
    // MARK: - Filtering Logic
    
    /// Sorts the coins based on the selected filter and updates the 'currentCoins'.
    func applyFilter(_ filter: CoinFilter) {
        self.currentFilter = filter
        
        switch filter {
        case .marketCap:
            currentCoins = rawFetchedCoins.sorted { $0.rank < $1.rank } // API ranks by market cap
        case .price(let order):
            currentCoins = rawFetchedCoins.sorted { (coin1, coin2) -> Bool in
                guard let p1 = Double(coin1.price ?? "0"),
                      let p2 = Double(coin2.price ?? "0") else { return false }
                return order == .descending ? (p1 > p2) : (p1 < p2)
            }
        case .change24h(let order):
            currentCoins = rawFetchedCoins.sorted { (coin1, coin2) -> Bool in
                guard let c1 = Double(coin1.change ?? "0"),
                      let c2 = Double(coin2.change ?? "0") else { return false }
                return order == .descending ? (c1 > c2) : (c1 < c2)
            }
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
}
