//
//  CoinListRow.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import Charts // Requires Swift Charts framework (iOS 16+)

// A simple structure to hold only the data required for the sparkline chart
struct ChartPoint: Identifiable {
    // We use the index of the point in the array as the ID
    let id: Int
    let value: Double
}

struct CoinListRow: View {
    let coin: Coin
    
    private var coinBackgroundColor: Color {
        // Use the coin's color, or fall back to a default dark gray
        return Color(hex: coin.color ?? "#333333")
    }
    
    // Convert sparkline Strings to Double for Chart use
    private var chartData: [ChartPoint] {
        return coin.sparkline
            .compactMap { $0 } // Filter out nulls
            .compactMap { Double($0) } // Convert valid strings to Doubles
        // The key change: use enumerated() to get the index (id)
            .enumerated()
            .map { index, value in ChartPoint(id: index, value: value) }
    }
    
    // Determine the color for the percentage change and the sparkline
    private var changeColor: Color {
        guard let changeValue = Double(coin.change ?? "0") else { return .gray }
        return changeValue >= 0 ? .green : .red
    }
    
    // MARK: - View Body
    var body: some View {
        HStack {
            // 1. Coin Icon and Name (Left Side)
            HStack(spacing: 12) {
                WebImage(url: URL(string: coin.iconUrl ?? "")){ image in
                    image.image?.resizable()
                }
                // Must use the .onSuccess modifier to enable SVG decoding
                .onSuccess { image, data, cacheType in
                    // This block ensures the SVG decoder runs successfully
                    // SDWebImage relies on the SDWebImageSVGCoder for this
                }
                .onFailure{error in
                    print("Error Loading Image \(error) \n \(coin.iconUrl ?? "")")
                }
                .indicator(.activity) // Show a loading indicator
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(coin.symbol)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(coin.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
            }
            Spacer()
            
            // 2. Sparkline Chart (Middle)
            Group {
                if #available(iOS 16.0, *) { // Charts is available in iOS 16+
                    Chart(chartData) { point in
                        LineMark(
                            x: .value("Index", chartData.firstIndex(where: { $0.id == point.id }) ?? 0),
                            y: .value("Price", point.value)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(changeColor) // Match chart color to change
                    }
                    .chartYAxis(.hidden)
                    .chartXAxis(.hidden)
                } else {
                    // Fallback view for older OS versions
                    Text("Graph Unavailable")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, height: 40)
            .padding(.horizontal, 10)
            
            Spacer()
            
            // 3. Price and Change (Right Side)
            VStack(alignment: .trailing, spacing: 4) {
                Text("$ \(coin.price?.toCurrencyFormat() ?? "N/A")")
                    .font(.headline)
                    .foregroundColor(.black)
                HStack(spacing: 4) {
                    // Triangle for up/down
                    Image(systemName: Double(coin.change ?? "0") ?? 0 >= 0 ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.caption2)
                    
                    Text("\(coin.change ?? "0.00")%")
                        .font(.subheadline)
                }
                .foregroundColor(changeColor)
            }
        }
        // 1. Padding inside the card (keeps content away from card edges)
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .background(coinBackgroundColor.opacity(0.15))
        .cornerRadius(10)
        
        // 2.Padding outside the card (creates the margin)
        .padding(.horizontal, 8)
        .padding(.vertical, 0)
    }
}


#Preview {
    // 1. Create a concrete instance of a Coin model for the preview
    // NOTE: This sample data must perfectly match the structure of your Coin struct.
    let sampleCoin = Coin(
        uuid: "Qwsogvtv82FCd",
        rank: 1,
        name: "Bitcoin",
        symbol: "BTC",
        iconUrl: "https://cdn.coinranking.com/UJ-dQdgYY/8085.png",
        price: "65432.12345",
        change: "-1.57", // Negative change for visual test
        marketCap: "1287654321234",
        color: "#f7931A",
        // Sample sparkline data (strings) with a mix of values for the chart
        sparkline: [
            "9515.0454185372",
            "9540.1812284677",
            "9554.2212643043",
            "9593.571539283"
        ]
    )
    
    // 2. Wrap the CoinListRow in a container (like a VStack) for context
    VStack {
        Spacer()
        // Coin with negative change (red/down)
        CoinListRow(coin: sampleCoin)
        // Coin with positive change (green/up)
        CoinListRow(coin: Coin(
            uuid: "rhYdvQdEF",
            rank: 2,
            name: "Ethereum",
            symbol: "ETH",
            iconUrl: "https://cdn.coinranking.com/iImvX5-OG/5426.png",
            price: "3997.654",
            change: "2.89",
            marketCap: "450987654321",
            color: "#627EEA",
            // Sample sparkline data showing an overall increase
            sparkline: [
                "0.9989504570557836",
                "0.9983877836406384",
                "0.9980832967019606",
                "0.9991024864845068"
            ]
        ))
        Spacer()
    }
    // Apply a dark background to match the application's look
    .background(Color.white)
    .preferredColorScheme(.light)
}
