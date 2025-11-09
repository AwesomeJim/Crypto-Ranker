//
//  CoinListRow.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftUICharts

// A simple structure to hold only the data required for the sparkline chart
struct ChartPoint: Identifiable {
    // We use the index of the point in the array as the ID
    let id: Int
    let value: Double
}

struct CoinListRow: View {
    let coin: Coin
    
    private var coinBgColor: Color {
        // Use the coin's color, or fall back to a default dark gray
        return Color(hex: coin.color ?? "#333333")
    }
    
    private var chartData: LineChartData {
        // 1. Convert sparkline strings to Doubles
        let points = coin.sparkline.compactMap { Double($0 ?? "") }
        
        // 2. Create a DataSet and the final LineChartData
        let dataSet = LineDataSet(
            dataPoints: points.map { LineChartDataPoint(value: $0) },
            pointStyle: PointStyle(),
            style: LineStyle(lineColour: ColourStyle(colour: coinBgColor), lineType: .line)
        )
        
        return LineChartData(dataSets: dataSet)
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
                //use the .onSuccess modifier to enable SVG decoding
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
                        .foregroundColor(.primary)
                    Text(coin.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
            }
            Spacer()
            // 2. Sparkline Chart (Middle)
            VStack {
                LineChart(chartData: chartData)
                // Set the ID to force SwiftUI to redraw when data changes
                    .id(chartData.id)
                    .frame(width: 80, height: 40) // Ensure it fits in the row
            }
            
            Spacer()
            
            // 3. Price and Change (Right Side)
            VStack(alignment: .trailing, spacing: 4) {
                Text("$ \(coin.price?.toCurrencyFormat() ?? "N/A")")
                    .font(.headline)
                    .foregroundColor(.primary)
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
        .coinCardStyle(hexColor: coin.color ?? "#333333")
        .padding(.vertical, 0)
    }
}


#Preview {
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
        // Sample sparkline data
        sparkline: [
            "9515.0454185372",
            "9540.1812284677",
            "9554.2212643043",
            "9593.571539283",
        ]
    )
    
    
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
    .preferredColorScheme(.dark)
}
