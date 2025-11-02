//
//  CoinDetail.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

struct CoinDetail: Codable {
    let uuid: String
    let name: String
    let symbol: String
    let description: String? // Long text description
    let iconUrl: String?
    let websiteUrl: String?
    let price: String?
    let rank: Int
    let marketCap: String?
    let volume24h: String?
    let change: String?
    let color: String?
    
    // You'll need an array of links for 'Other Statistics'
    let links: [CoinLink]?
}


struct CoinHistoryResponse: Codable {
    let status: String
    let data: CoinHistoryData
}

struct CoinHistoryData: Codable {
    // The history property contains an array of price/timestamp points
    let history: [HistoryPoint]
}

struct HistoryPoint: Codable {
    // Both price and timestamp are often returned as Strings in APIs
    let price: String?
    let timestamp: Int // Unix timestamp
}
