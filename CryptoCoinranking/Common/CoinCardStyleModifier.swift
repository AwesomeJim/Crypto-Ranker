//
//  CoinCardStyleModifier.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 09/11/2025.
//

import SwiftUI

struct CoinCardStyleModifier: ViewModifier {
    let hexColor: String
    
    // Access the current environment color scheme
    @Environment(\.colorScheme) var colorScheme

    // 1. Define the dynamic brand color
    private var coinBackgroundColor: Color {
        // Ensure you handle nil/invalid hex here if necessary
        return Color(hex: hexColor)
    }
    
    // 2. Define the conditional background color
    private var rowBackgroundColor: Color {
        if colorScheme == .dark {
            // Use a constant gray color for visibility in Dark Mode
            return Color(uiColor: .gray).opacity(0.50)
        } else {
            // Use the coin's specific brand color in Light Mode
            return coinBackgroundColor.opacity(0.15)
        }
    }
    
    // 3. Define the border color
    private var rowBorderColor: Color {
        // Use the brand color for the border in both modes for subtle branding
        return coinBackgroundColor.opacity(0.15)
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 16)
            .background(rowBackgroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(rowBorderColor, lineWidth: 1)
            )
            // Apply outer margins (separates cards in the list)
            .padding(.horizontal, 8)
    }
}
