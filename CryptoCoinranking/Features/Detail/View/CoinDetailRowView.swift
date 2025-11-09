//
//  CoinDetailRowView.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 09/11/2025.
//

import SwiftUI

struct CoinDetailRowView: View {
    // 1. Inputs required from the ViewModel/Parent View
    let title: String
    let detail: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Example: "About Bitcoin"
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary) // Adaptive text color
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary) // Subtle detail text
            }
            .padding(.vertical, 4)

            Spacer()
        }
        .padding(.horizontal, 20) // Horizontal padding for separation from screen edges
        .background(Color.clear) // Ensure the row doesn't hide the main background
    }
}
