//
//  String+Extensions.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import Foundation

extension String {
    /**
     Formats a numeric string into currency format (e.g., "12345.678" -> "12,345.68").
     Returns the original string if conversion fails.
    */
    func toCurrencyFormat(maxDecimals: Int = 2) -> String {
        // 1. Attempt to convert the string to a Double
        guard let doubleValue = Double(self) else {
            return self // Return original string if it's not a valid number
        }
        
        // 2. Use NumberFormatter for robust, locale-aware formatting
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maxDecimals
        formatter.minimumFractionDigits = 2 // Ensure at least 2 decimal places
        formatter.groupingSeparator = "," // For comma grouping
        
        // 3. Format the number
        return formatter.string(from: NSNumber(value: doubleValue)) ?? self
    }
}
