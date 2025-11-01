//
//  NetworkServiceProtocol.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation

// Protocol for Dependency Injection and Testing
protocol NetworkServiceProtocol {
    func fetchCoins(offset: Int, limit: Int) async throws -> CoinResponse
    
    // New methods for Coin Detail Page
    func fetchCoinDetails(uuid: String) async throws -> CoinDetailResponse
    func fetchCoinHistory(uuid: String, timePeriod: String) async throws -> CoinHistoryResponse
}
