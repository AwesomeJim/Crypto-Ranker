//
//  NetworkError.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import Foundation

// Custom Error Enum
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case apiError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL was invalid. Please check the endpoint."
        case .invalidResponse:
            return "The server returned an invalid or unsuccessful response."
        case .decodingError(let error):
            return "Failed to decode the data: \(error.localizedDescription)"
        case .apiError(let message):
            return "API Error: \(message)"
        }
    }
}


func logError(_ obj: Any?) {
    debugPrint("❌: \(String(describing: obj))")
}
func logInfo(_ obj: Any?) {
    debugPrint("✅: \(String(describing: obj))")
}
