//
//  View_Extensions.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 09/11/2025.
//

import SwiftUI

extension View {
    func coinCardStyle(hexColor: String) -> some View {
        modifier(CoinCardStyleModifier(hexColor: hexColor))
    }
}
