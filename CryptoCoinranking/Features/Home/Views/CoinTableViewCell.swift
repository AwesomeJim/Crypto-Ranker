//
//  CoinTableViewCell.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import UIKit
import SwiftUI

final class CoinTableViewCell: UITableViewCell {
    
    // The UIHostingController is instantiated once
    private var hostingController: UIHostingController<CoinListRow>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Initial setup for the cell's appearance
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Method
    
    func configure(with coin: Coin) {
        // If the hostingController is nil, set it up for the first time
        if hostingController == nil {
            let rowView = CoinListRow(coin: coin)
            hostingController = UIHostingController(rootView: rowView)
            
            // Critical: Add the hosted view to the cell's content view
            guard let hostedView = hostingController?.view else { return }
            
            hostedView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(hostedView)
            
            NSLayoutConstraint.activate([
                hostedView.topAnchor.constraint(equalTo: contentView.topAnchor),
                hostedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hostedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hostedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            hostedView.backgroundColor = .clear
        } else {
            // If the hostingController exists, simply update its rootView
            hostingController?.rootView = CoinListRow(coin: coin)
        }
    }
    
    // Ensure the hosting controller is deallocated correctly
    override func prepareForReuse() {
        super.prepareForReuse()
        // No explicit cleanup needed here, but good practice to keep the method
    }
}
