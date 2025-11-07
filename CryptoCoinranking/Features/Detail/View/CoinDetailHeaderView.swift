//
//  CoinDetailHeaderView.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct CoinDetailHeaderView: View {
    
    @ObservedObject var viewModel: CoinDetailViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            // Coin Icon
            WebImage(url: URL(string: viewModel.coinDetails?.iconUrl ?? ""))
                .resizable()
                .onSuccess { image, data, cacheType in
                    // SVG decoding trigger
                }
                .frame(width: 40, height: 50)
                .clipShape(Circle())
            
            // Coin Name & Symbol
            Text(viewModel.coinDetails?.name ?? "N/A")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(viewModel.coinDetails?.symbol ?? "N/A")
                .font(.title3)
                .foregroundColor(.gray)
            
            // Price, Change, Rank Summary (HStack)
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Price in USD")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(viewModel.formattedPrice)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading) {
                    Text("24h Change")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack(spacing: 4) {
                        // Triangle for up/down
                        Image(systemName: Double(viewModel.coinDetails?.change ?? "0") ?? 0 >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .font(.caption2)
                        
                        Text("\(viewModel.formattedChange)%")
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(Double(viewModel.coinDetails?.change ?? "0") ?? 0 >= 0 ? .green : .red)
                    
                }
                
                VStack(alignment: .leading) {
                    Text("Rank")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(viewModel.formattedRank)
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 20)
    }
}

#Preview {
    
    let mockNetwork = MockNetworkService()
    let mockFavorites = FavoritesManager.shared
    
    // 2. Instantiate the ViewModel (using placeholder data)
    let mockViewModel = CoinDetailViewModel(
        coinUUID: "btc-bitcoin",
        networkService: mockNetwork,
        favoritesManager: mockFavorites
    )
    
    let sampleDetail = CoinDetail(
        uuid: "btc-bitcoin",
        name: "Bitcoin",
        symbol: "BTC",
        description: "The original cryptocurrency.",
        iconUrl: "https://cdn.coinranking.com/bOabBYkcX/bitcoin.svg",
        websiteUrl: "https://bitcoin.org",
        price: "69420.15",
        rank: 1 ,// Test negative change
        marketCap: "1350000000000",
        volume24h: "8500000000",
        change: "1.34",
        color: "#f7931A",
        links: []
    )
    
    // Set the published property on the main queue
    mockViewModel.coinDetails = sampleDetail
    
    // Example for a positive change coin
    let positiveDetail = CoinDetail(
        uuid: "eth-ethereum",
        name: "Ethereum",
        symbol: "ETH",
        description: "",
        iconUrl: "https://cdn.coinranking.com/B1pE_D9Yy/ethereum.svg",
        websiteUrl: "https://bitcoin.org",
        price: "4200.75",
        rank: 2,
        marketCap: "500000000000",
        volume24h: "8500000000",
        change: "-1.98",
        color: "#627EEA",
        links: []
    )
    let positiveVM = CoinDetailViewModel(coinUUID: "eth-ethereum", networkService: mockNetwork, favoritesManager: mockFavorites)
    positiveVM.coinDetails = positiveDetail
    // 2. Return the View
    return VStack {
        CoinDetailHeaderView(viewModel: mockViewModel)
        CoinDetailHeaderView(viewModel: positiveVM) // Use the separate positive VM
        
        Spacer()
    }
    .background(Color.black)
    .preferredColorScheme(.dark)
}


// Simple placeholder class needed to satisfy the ViewModel's initializer
class MockNetworkService: NetworkServiceProtocol {
    func fetchCoinDetails(uuid: String) async throws -> CoinDetailResponse {
        fatalError("Mock not implemented")
    }
    func fetchCoinHistory(uuid: String, timePeriod: String) async throws -> CoinHistoryResponse {
        fatalError("Mock not implemented")
    }
    func fetchCoins(offset: Int, limit: Int) async throws -> CoinResponse {
        fatalError("Mock not implemented")
    }
}
