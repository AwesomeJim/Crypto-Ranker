//
//  DetailFactoryProtocol.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import UIKit

protocol DetailFactoryProtocol {
    // Factory returns the ViewModel, not the fully assembled VC
    func makeDetailViewModel(for coinUUID: String) -> CoinDetailViewModel
}

final class CoinDetailFactory: DetailFactoryProtocol {
    
    private let networkService: NetworkServiceProtocol
    private let favoritesManager: FavoritesManagerProtocol
    
    init(networkService: NetworkServiceProtocol, favoritesManager: FavoritesManagerProtocol) {
        self.networkService = networkService
        self.favoritesManager = favoritesManager
    }
    
    // Centralized ViewModel creation
    func makeDetailViewModel(for coinUUID: String) -> CoinDetailViewModel {
        return CoinDetailViewModel(
            coinUUID: coinUUID,
            networkService: networkService,
            favoritesManager: favoritesManager
        )
    }
}
