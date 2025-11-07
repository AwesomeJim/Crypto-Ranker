//
//  AppError.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 07/11/2025.
//

import Foundation

struct AppError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
