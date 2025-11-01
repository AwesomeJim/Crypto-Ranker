//
//  NetworkService.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//
import Foundation

// The main Network Service implementation
class NetworkService: NetworkServiceProtocol {
    
    
    // Base URL for the CoinRanking API
    private let baseURL = "https://api.coinranking.com/v2"
    
   
    // MARK: - Core Fetch Function (Generic and Reusable)
    
    // This is a generic function that handles the decoding for any Codable type
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        // Create the URLRequest, including the necessary API key header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(AppConfig.coinRankingAPIKey, forHTTPHeaderField: "x-access-token")
        
        // 1. Perform the network request using async/await
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 2. Check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            // Throw a custom error if the status code is bad (e.g., 401, 404, 500)
            throw NetworkError.invalidResponse
        }
        
        // 3. Decode the data
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // Throw a custom error if decoding fails
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - API Endpoints
    
    // Implements the function required by the protocol for pagination
    func fetchCoins(offset: Int, limit: Int) async throws -> CoinResponse {
        // Construct the URL with query parameters for pagination
        guard var urlComponents = URLComponents(string: "\(AppConfig.baseURL)/coins") else {
            throw NetworkError.invalidURL
        }
        
        // Add query items for pagination and currency (optional but good practice)
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "referenceCurrencyUuid", value: "yhjMzLPhuIDl") // UUID for USD
        ]
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // Use the generic fetcher to get the CoinResponse
        return try await fetch(url: url)
    }
    
}
