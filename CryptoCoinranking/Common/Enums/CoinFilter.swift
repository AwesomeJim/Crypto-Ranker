//
//  CoinFilter.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation

enum CoinFilter: CaseIterable {
    case marketCap(SortOrder) // Default sorting is by Market Cap
    case price(SortOrder)
    case change24h(SortOrder)
    
    
    // MARK: - CaseIterable Conformance
   
    static var allCases: [CoinFilter] {
        return [
            // List the primary options the user will see in the filter menu
            .marketCap(.descending),
            .price(.descending),
            .change24h(.descending)
        ]
    }
    
    // Enum to handle ascending or descending order
    enum SortOrder {
        case descending
        case ascending
    }
    
    var title: String {
        switch self {
        case .marketCap(.descending): return "Rank (Highest Cap)"
        case .price(.descending): return "Highest Price"
        case .change24h(.descending): return "Best 24h Performance"
        default: return "Custom Sort" // Simpler titles for the UI menu
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case oneDay = "1h" 
    case sevenDays = "7d"
    case thirtyDays = "30d"
    case oneYear = "1y"
    case threeYears = "3y"
    case fiveYears = "5y"
    
    var title: String {
        switch self {
        case .oneDay: return "24H"
        case .sevenDays: return "7D"
        case .thirtyDays: return "30D"
        case .oneYear: return "1Y"
        case .threeYears: return "3Y"
        case .fiveYears: return "5Y"
        }
    }
}
