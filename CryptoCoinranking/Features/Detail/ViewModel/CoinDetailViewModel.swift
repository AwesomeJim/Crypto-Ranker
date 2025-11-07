//
//  CoinDetailViewModel.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import Foundation
internal import Combine

final class CoinDetailViewModel: ObservableObject{
    
    // MARK: - Dependencies & State
    
    private let networkService: NetworkServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    private let coinUUID: String // The ID passed from the list screen
    
    // Data Sources for the View Controller
    //Change closures to published properties
    @Published var coinDetails: CoinDetail?
    @Published private(set) var coinHistory: [HistoryPoint] = []
    
    // User interaction state
    private(set) var currentPeriod: TimePeriod = .sevenDays
    
    // MARK: - Initialization
    init(coinUUID: String, networkService: NetworkServiceProtocol, favoritesManager: FavoritesManagerProtocol) {
        self.coinUUID = coinUUID
        self.networkService = networkService
        self.favoritesManager = favoritesManager
    }
    
    // MARK: - API Fetching Logic
    
    /// Fetches both the coin's static details and its historical data.
    @MainActor
    func fetchAllData() async {
        // Fetch details (runs concurrently with history fetch)
        await fetchCoinDetails()
        
        // Fetch history for the default period
        await fetchCoinHistory(for: currentPeriod)
    }
    
    /// Fetches only the static coin details.
    @MainActor
    private func fetchCoinDetails() async {
        do {
            let response = try await networkService.fetchCoinDetails(uuid: coinUUID)
            self.coinDetails = response.data.coin
        } catch {
            logInfo("Failed to fetch coin details: \(error.localizedDescription)")
            // TODO: Communicate error state to the View Controller
        }
    }
    
    /// Fetches historical data for a specific time period (triggered by user interaction).
    @MainActor
    func fetchCoinHistory(for period: TimePeriod) async {
        guard period != currentPeriod || coinHistory.isEmpty else { return }
        
        // Immediately set the new period to avoid duplicate calls
        self.currentPeriod = period
        
        do {
            // Pass the raw value of the enum to the network layer
            let response = try await networkService.fetchCoinHistory(uuid: coinUUID, timePeriod: period.rawValue)
            self.coinHistory = response.data.history
        } catch {
            logInfo("Failed to fetch coin history for \(period): \(error.localizedDescription)")
            // TODO: Communicate error state to the View Controller
            self.coinHistory = [] // Clear old data on failure
        }
    }
    
    // MARK: - Favorites Logic (for the Star/Heart Button)
    
    var isFavorite: Bool {
        return favoritesManager.isFavorite(uuid: coinUUID)
    }
    
    func toggleFavoriteStatus() {
        if isFavorite {
            favoritesManager.removeFavorite(uuid: coinUUID)
        } else {
            favoritesManager.addFavorite(uuid: coinUUID)
        }
    }
    
    // MARK: - Formatting and Presentation Helpers
    
    // Format the rank with a "#"
    var formattedRank: String {
        guard let rank = coinDetails?.rank else { return "N/A" }
        return "#\(rank)"
    }
    
    // Format price using the utility extension
    var formattedPrice: String {
        return coinDetails?.price?.toCurrencyFormat() ?? "N/A"
    }
    
    // Format change percentage
    var formattedChange: String {
        return coinDetails?.change?.toCurrencyFormat(maxDecimals: 2) ?? "N/A"
    }
}
