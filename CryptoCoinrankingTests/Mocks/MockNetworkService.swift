//
//  MockNetworkService.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 09/11/2025.
//

import XCTest
import Combine
@testable import CryptoCoinranking

// A simple mock error for testing
struct MockError: Error, LocalizedError {
    var errorDescription: String? { "A mock network error occurred." }
}


// 1. Mock the Network Service (MUST return controlled data)
class MockNetworkService: NetworkServiceProtocol {
  
        var mockCoins: [Coin] = []
        var shouldThrowError = false
        
        // We can use this to check if the correct parameters were passed
        private(set) var lastFetchOffset: Int?
        
    
        func fetchCoins(offset: Int, limit: Int) async throws -> CoinResponse {
            lastFetchOffset = offset
            if shouldThrowError {
                throw MockError()
            }
            
          
            
            let data = CoinData(coins: mockCoins)
            return CoinResponse(status: "success", message: nil, data: data)
        }
        
       
        func fetchCoinDetails(uuid: String) async throws -> CoinDetailResponse {
            fatalError("MockNetworkService.fetchCoinDetails not implemented")
        }
        
        func fetchCoinHistory(uuid: String, timePeriod: String) async throws -> CoinHistoryResponse {
            fatalError("MockNetworkService.fetchCoinHistory not implemented")
        }
}
