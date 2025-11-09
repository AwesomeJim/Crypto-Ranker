//
//  EmptyFavoritesView.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import SwiftUI

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
            
            Text("No Favorite Coins Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Text("Swipe left and Tap the heart icon on any coin in the 'Cryto' tab to add it here and track your watchlist.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.01)) 
        .preferredColorScheme(.dark)
    }
}

// Preview
#Preview {
    EmptyFavoritesView()
        .background(Color.white)
}
