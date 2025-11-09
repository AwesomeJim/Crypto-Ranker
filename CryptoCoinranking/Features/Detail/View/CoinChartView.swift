//
//  CoinChartView.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import UIKit
import SwiftUI
import SwiftUICharts

// We define a simple SwiftUI view to wrap the chart logic
struct CoinChartView: View {
    let history: [HistoryPoint]
    let color: String // Use the coin's color for the chart line

    private var chartData: LineChartData {
        // 1. Convert sparkline strings to Doubles
        let points = history.compactMap { Double($0.price ?? "") }
        
        // 2. Create a DataSet and the final LineChartData
        let dataSet = LineDataSet(
            dataPoints: points.map { LineChartDataPoint(value: $0) },
            pointStyle: PointStyle(), // Default point style
            style: LineStyle(lineColour: ColourStyle(colour: Color(hex: color)), lineType: .curvedLine)
        )
        
        return LineChartData(dataSets: dataSet)
    }
    
    
    var body: some View {
        VStack {
            LineChart(chartData: chartData)
            // Set the ID to force SwiftUI to redraw when data changes
                .id(chartData.id)
                .frame(height: 200)
                .yAxisLabels(chartData: chartData)
        }
        .coinCardStyle(hexColor: color)
        .padding(.vertical, 0)
    }
}
