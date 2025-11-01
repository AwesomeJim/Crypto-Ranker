//
//  NetworkServiceProtocol.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation

// 1. Protocol for Dependency Injection and Testing
protocol NetworkServiceProtocol {
    func fetchCoins(offset: Int, limit: Int) async throws -> CoinResponse
}
