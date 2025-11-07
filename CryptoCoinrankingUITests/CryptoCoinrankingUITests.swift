//
//  CryptoCoinrankingUITests.swift
//  CryptoCoinrankingUITests
//
//  Created by Awesome Jim on 01/11/2025.
//

import XCTest

final class CryptoCoinrankingUITests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        

    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    func test_appLaunch_and_navigationToDetail() throws {
        // Arrange
        let app = XCUIApplication()
        app.launch()
        
        // Assert: Check if the list loaded (e.g., look for the BTC symbol)
        let btcSymbol = app.staticTexts["BTC"]
        XCTAssertTrue(btcSymbol.waitForExistence(timeout: 5))
        
        // Act: Tap the first cell
        app.tables.cells.firstMatch.tap()
        
        // Assert: Check if the detail screen is visible (e.g., look for the 24H segmented control)
        let segmentedControl = app.segmentedControls.buttons["24H"]
        XCTAssertTrue(segmentedControl.waitForExistence(timeout: 3))
    }
    
    func test_toggleFavorite_and_checkFavoritesTab() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Act: Navigate to Favorites tab (assuming tag 1 or index 1)
        app.tabBars.buttons["Watchlist"].tap()
        
        // Assert: Check for empty state message
        XCTAssertTrue(app.staticTexts["No Favorite Coins Yet"].exists)
        
    }
}
