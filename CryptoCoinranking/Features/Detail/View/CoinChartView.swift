//
//  CoinChartView.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import UIKit
import SwiftUI // For hosting the chart/time controls
import Charts // For the chart view

// We define a simple SwiftUI view to wrap the chart logic
struct CoinChartView: View {
    let history: [HistoryPoint]
    let color: String // Use the coin's color for the chart line
    
    // Convert HistoryPoint to ChartPoint for SwiftUI Charts
    private var chartData: [ChartPoint] {
        return history.enumerated()
            .compactMap { index, point in
                guard let price = Double(point.price ?? "0") else { return nil }
                return ChartPoint(id: index, value: price)
            }
    }
    
    // Determine the line color from the hex string
    private var lineColor: Color {
        // NOTE: A real implementation requires a Hex to UIColor/Color converter
        return color.isEmpty ? .blue : .purple // Placeholder color
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            Chart(chartData) { point in
                LineMark(
                    x: .value("Time", point.id),
                    y: .value("Price", point.value)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(lineColor)
            }
            .chartYAxis(.hidden)
            .chartXAxis(.hidden)
            .frame(height: 200)
            .padding()
        } else {
            Text("Charts require iOS 16+")
        }
    }
}
