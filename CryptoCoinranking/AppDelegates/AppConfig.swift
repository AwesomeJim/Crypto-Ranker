//
//  AppConfig.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation

struct AppConfig {
    // Retrieves the API Key from Info.plist
    static var coinRankingAPIKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "CoinRankingAPIKey") as? String else {
            fatalError("CoinRankingAPIKey must be set in Info.plist (via .xcconfig)")
        }
        return key
    }
    
    // Retrieves the Base URL from Info.plist
    static var baseURL: String {
        guard let url = Bundle.main.object(forInfoDictionaryKey: "CoinRankingAPIBaseURL") as? String else {
            fatalError("CoinRankingAPIBaseURL must be set in Info.plist (via .xcconfig)")
        }
        return url
    }
    
    
    //Other necessary constants (like the USD UUID)
    static let defaultReferenceCurrencyUUID: String = "yhjMzLPhuIDl"
}
