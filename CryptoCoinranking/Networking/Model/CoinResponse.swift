//
//  CoinResponse.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

// MARK: - Top Level Response
struct CoinResponse: Codable {
    let status: String
    let message: String?
    let data: CoinData?
}
