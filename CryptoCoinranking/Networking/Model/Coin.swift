//
//  Coin.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

// MARK: - Coin
// This is the model for a single coin, containing all the coin
// properties
struct Coin: Codable{
    let uuid: String
    let rank: Int
    let name: String
    let symbol: String
    
    // These are optional because the API can send 'null'
    let iconUrl: String?
    let price: String?
    let change: String?
    let marketCap: String?
    let color: String?
    let sparkline: [String?]
    
    //Custom memberwise initializer for manual creation (like previews)
    init(uuid: String, rank: Int, name: String, symbol: String, iconUrl: String?, price: String?, change: String?, marketCap: String?, color: String?, sparkline: [String?]) {
        self.uuid = uuid
        self.rank = rank
        self.name = name
        self.symbol = symbol
        self.iconUrl = iconUrl
        self.price = price
        self.change = change
        self.marketCap = marketCap
        self.color = color
        self.sparkline = sparkline
    }
    
    // MARK: - Codable Initializer
    private enum CodingKeys: String, CodingKey {
        case uuid, rank, name, symbol, iconUrl, price, change, marketCap, color, sparkline
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        uuid = try container.decode(String.self, forKey: .uuid)
        rank = try container.decode(Int.self, forKey: .rank)
        name = try container.decode(String.self, forKey: .name)
        symbol = try container.decode(String.self, forKey: .symbol)
        
        // Decode optional properties using decodeIfPresent.
        // This will safely assign 'nil' if the key is missing or 'null'.
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        change = try container.decodeIfPresent(String.self, forKey: .change)
        marketCap = try container.decodeIfPresent(String.self, forKey: .marketCap)
        color = try container.decodeIfPresent(String.self, forKey: .color)
        
        sparkline = try container.decodeIfPresent([String?].self, forKey: .sparkline) ?? []
        
    }
    
    
}
