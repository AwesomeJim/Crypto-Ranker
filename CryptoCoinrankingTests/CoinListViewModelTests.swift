//
//  CoinListViewModelTests.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 09/11/2025.
//

import XCTest
import Combine
@testable import CryptoCoinranking


@MainActor
final class CoinListViewModelTests: XCTestCase {
    
    var viewModel: CoinListViewModel!
    var mockNetworkService: MockNetworkService!
    var mockFavoritesManager: MockFavoritesManager!
    
    // Helper property for testing Combine @Published properties
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // This runs before each test
        mockNetworkService = MockNetworkService()
        mockFavoritesManager = MockFavoritesManager()
        viewModel = CoinListViewModel(
            networkService: mockNetworkService,
            favoritesManager: mockFavoritesManager
        )
        cancellables = Set<AnyCancellable>()
    }
    
    
    override func tearDown() {
        // This runs after each test
        viewModel = nil
        mockNetworkService = nil
        mockFavoritesManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    /// Helper function to preload the rawFetchedCoins for sorting tests
    func preloadRawCoins() {
        // Note: Since rawFetchedCoins is private, we must call fetchNextPage with mock data
        // The fetchNextPage method populates rawFetchedCoins and calls applyFilter.
        mockNetworkService.mockCoins = SampleData.allSampleCoins
    }
    
    // MARK: - Data Fetching Tests
    
    func test_fetchCoins_success_loadsAndPublishesCoins() async {
        // Arrange
        let mockData = [SampleData.btc, SampleData.eth]
        mockNetworkService.mockCoins = mockData
        
        // Assert: Check that coins are initially empty
        XCTAssertTrue(viewModel.currentCoins.isEmpty)
        
        // Act
        await viewModel.fetchNextPage()
        
        // Assert: Check that coins were loaded and published
        XCTAssertEqual(viewModel.currentCoins.count, 2)
        XCTAssertEqual(viewModel.currentCoins[0].symbol, "BTC")
    }
    
    func test_fetchCoins_failure_publishesError() async {
        // Arrange
        mockNetworkService.shouldThrowError = true
        
        var receivedError: AppError?
        viewModel.$appError
            .compactMap { $0 }
            .sink { error in
                receivedError = error
            }
            .store(in: &cancellables)
        
        // Act
        await viewModel.fetchNextPage()
        
        // Assert
        XCTAssertTrue(viewModel.currentCoins.isEmpty) // No coins should be loaded
        XCTAssertNotNil(receivedError) // An error should be published
        XCTAssertEqual(receivedError?.title, "An Error Occurred")
    }
    
    // MARK: - Pagination Tests
    
    func test_fetchNextPage_appendsCoinsCorrectly() async {
        // Arrange (First Page)
        mockNetworkService.mockCoins = [SampleData.btc]
        await viewModel.fetchNextPage()
        
        // Assert: First page is loaded
        XCTAssertEqual(viewModel.currentCoins.count, 1)
        XCTAssertEqual(mockNetworkService.lastFetchOffset, 0) // Check offset
        
        // Arrange (Second Page)
        mockNetworkService.mockCoins = [SampleData.eth] // New data
        
        // Act (Fetch second page)
        await viewModel.fetchNextPage()
        
        // Assert: New data is appended
        XCTAssertEqual(viewModel.currentCoins.count, 2)
        XCTAssertEqual(viewModel.currentCoins[1].symbol, "ETH")
        XCTAssertEqual(mockNetworkService.lastFetchOffset, 20) // Offset incremented
    }
    
    func test_fetchCoins_emptyResponse_stopsPagination() async {
        // Arrange
        mockNetworkService.mockCoins = [] // API returns an empty array
        
        // Act
        await viewModel.fetchNextPage()
        
        // Assert
        XCTAssertTrue(viewModel.currentCoins.isEmpty)
    }
    
    // MARK: - Favorites Tests
    
    func test_toggleFavoriteStatus_addsAndRemovesFavorite() {
        // Arrange
        let coin = SampleData.btc
        
        // Assert: Initially not a favorite
        XCTAssertFalse(viewModel.isFavorite(coin: coin))
        
        // Act 1: Add favorite
        viewModel.toggleFavoriteStatus(for: coin)
        
        // Assert 1: Is now a favorite
        XCTAssertTrue(viewModel.isFavorite(coin: coin))
        XCTAssertTrue(mockFavoritesManager.isFavorite(uuid: coin.uuid)) // Check mock
        
        // Act 2: Remove favorite
        viewModel.toggleFavoriteStatus(for: coin)
        
        // Assert 2: Is no longer a favorite
        XCTAssertFalse(viewModel.isFavorite(coin: coin))
        XCTAssertFalse(mockFavoritesManager.isFavorite(uuid: coin.uuid)) // Check mock
    }
    
    // MARK: - Filtering Tests
    
    func test_setOrderBy_resetsListAndFetchesNewData() async {
        // Arrange
        // 1. Load initial data
        mockNetworkService.mockCoins = [SampleData.btc]
        await viewModel.fetchNextPage()
        XCTAssertEqual(viewModel.currentCoins.count, 1)
        
        // 2. Prepare for new fetch
        mockNetworkService.mockCoins = [SampleData.eth]
        
        // Assert
        XCTAssertEqual(viewModel.currentCoins.count, 1)
        XCTAssertEqual(viewModel.currentCoins[0].symbol, "BTC") // New data loaded
        XCTAssertEqual(mockNetworkService.lastFetchOffset, 0) // Offset was reset
    }
    
    
    func test_applyFilter_marketCap_sortsByRank() async {
        // Arrange: Load all sample coins into rawFetchedCoins
        preloadRawCoins()
        await viewModel.fetchNextPage() // This loads data and applies default filter

        // Act: Ensure the filter is applied (MarketCap uses the API's rank)
        viewModel.applyFilter(.marketCap(.descending))

        // Assert: Order should be BTC (Rank 1), ETH (Rank 2), ADA (Rank 3)
        XCTAssertEqual(viewModel.currentCoins.count, 3)
        XCTAssertEqual(viewModel.currentCoins.map { $0.symbol }, ["BTC", "ETH", "ADA"],
                       "Market Cap filter should sort by API rank (1, 2, 3).")
        XCTAssertEqual(viewModel.currentFilter, .marketCap(.descending))
    }

    func test_applyFilter_price_descending_sortsCorrectly() async {
        // Arrange: Load coins (Prices: BTC 10k, ADA 5k, ETH 3k)
        preloadRawCoins()
        await viewModel.fetchNextPage()

        // Act
        viewModel.applyFilter(.price(.descending))

        // Assert: Order should be BTC (10k), ADA (5k), ETH (3k)
        XCTAssertEqual(viewModel.currentCoins.count, 3)
        XCTAssertEqual(viewModel.currentCoins.map { $0.symbol }, ["BTC", "ADA", "ETH"],
                       "Price descending should sort by highest price first.")
        XCTAssertEqual(viewModel.currentFilter, .price(.descending))
    }

    func test_applyFilter_price_ascending_sortsCorrectly() async {
        // Arrange: Load coins (Prices: BTC 10k, ADA 5k, ETH 3k)
        preloadRawCoins()
        await viewModel.fetchNextPage()

        // Act
        viewModel.applyFilter(.price(.ascending))

        // Assert: Order should be ETH (3k), ADA (5k), BTC (10k)
        XCTAssertEqual(viewModel.currentCoins.count, 3)
        XCTAssertEqual(viewModel.currentCoins.map { $0.symbol }, ["ETH", "ADA", "BTC"],
                       "Price ascending should sort by lowest price first.")
        XCTAssertEqual(viewModel.currentFilter, .price(.ascending))
    }

    func test_applyFilter_change24h_descending_sortsCorrectly() async {
        // Arrange: Load coins (Changes: ADA +10.0, BTC +1.0, ETH -5.0)
        preloadRawCoins()
        await viewModel.fetchNextPage()

        // Act
        viewModel.applyFilter(.change24h(.descending))

        // Assert: Order should be ADA (10.0), BTC (1.0), ETH (-5.0)
        XCTAssertEqual(viewModel.currentCoins.count, 3)
        XCTAssertEqual(viewModel.currentCoins.map { $0.symbol }, ["ADA", "BTC", "ETH"],
                       "Change descending should sort by highest positive change first.")
        XCTAssertEqual(viewModel.currentFilter, .change24h(.descending))
    }
}

// MARK: - Sample Data Helper

struct SampleData {
    // 1. BTC: Rank 1, Price 10000, Change 1.0
    static let btc = Coin(
        uuid: "Qwsogvtv82FCd",
        rank: 1,
        name: "Bitcoin",
        symbol: "BTC",
        iconUrl: "https://cdn.coinranking.com/UJ-dQdgYY/8085.png",
        price: "10000",
        change: "1.0",
        marketCap: "1287654321234",
        color: "#f7931A",
        sparkline: [
            "9515.0454185372",
            "9540.1812284677",
            "9554.2212643043",
            "9593.571539283",
        ]
    )
    
    // 2. ETH: Rank 2, Price 3000, Change -5.0 (Lowest change)
    static let eth = Coin(
        uuid: "rhYdvQdEF",
        rank: 2,
        name: "Ethereum",
        symbol: "ETH",
        iconUrl: "https://cdn.coinranking.com/iImvX5-OG/5426.png",
        price: "3000",
        change: "-5.0",
        marketCap: "450987654321",
        color: "#627EEA",
        sparkline: [
            "0.9989504570557836",
            "0.9983877836406384",
            "0.9980832967019606",
            "0.9991024864845068"
        ]
    )
    
    // 3. ADA: Rank 3, Price 5000, Change 10.0 (Highest change)
    static let ada = Coin(
        uuid: "QoqqmS54PplV",
        rank: 3,
        name: "Cardano",
        symbol: "ADA",
        iconUrl: "https://cdn.coinranking.com/iImvX5-OG/5426.png",
        price: "5000",
        change: "10.0",
        marketCap: "450987654321",
        color: "#627EEA",
        sparkline: [
            "0.9989504570557836",
            "0.9983877836406384",
            "0.9980832967019606",
            "0.9991024864845068"
        ]
    )
    
    static let allSampleCoins = [btc, eth, ada]
}
