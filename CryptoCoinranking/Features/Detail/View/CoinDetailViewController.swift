//
//  CoinDetailViewController.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//
import UIKit
import SwiftUI

final class CoinDetailViewController: UIViewController {
    
    // MARK: - Dependencies
    var viewModel: CoinDetailViewModel!
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let timePeriodSegmentedControl = UISegmentedControl(items: TimePeriod.allCases.map { $0.title })
    private let detailLabel = UILabel()
    private let chartHostView = UIView() // Host for the SwiftUI Chart
    private let priceLabel = UILabel()
    private let rankLabel = UILabel()
    private let changeLabel = UILabel()
    
    required init?(coder: NSCoder) {
            // Must call super.init(coder:) when loading from a Storyboard.
            super.init(coder: coder)
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupNavigationBar()
        bindViewModel()
        
        // Initial data load
        Task { await viewModel.fetchAllData() }
    }
    
    // MARK: - Setup
    
    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Stack View
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        
        // Add Price/Rank/Change summary
        let summaryStack = UIStackView(arrangedSubviews: [priceLabel, changeLabel, rankLabel])
        summaryStack.axis = .horizontal
        summaryStack.distribution = .equalSpacing
        
        // Configure Labels
        priceLabel.font = .systemFont(ofSize: 32, weight: .bold)
        changeLabel.font = .systemFont(ofSize: 18)
        rankLabel.font = .systemFont(ofSize: 18)
        detailLabel.numberOfLines = 0
        
        // Configure Segmented Control
        timePeriodSegmentedControl.selectedSegmentIndex = TimePeriod.allCases.firstIndex(of: viewModel.currentPeriod) ?? 0
        timePeriodSegmentedControl.addTarget(self, action: #selector(timePeriodChanged), for: .valueChanged)
        
        // Build the hierarchy
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        stackView.addArrangedSubview(summaryStack)
        stackView.addArrangedSubview(timePeriodSegmentedControl)
        stackView.addArrangedSubview(chartHostView)
        stackView.addArrangedSubview(detailLabel)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -32) // Critical for vertical scrolling
        ])
    }
    
    private func setupNavigationBar() {
        // We'll set the title on details update
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(toggleFavorite))
        updateFavoriteButton()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // Update static details (name, price, rank, description)
        viewModel.onDetailsUpdate = { [weak self] in
            guard let self = self, let details = self.viewModel.coinDetails else { return }
            
            self.navigationItem.title = details.name
            self.priceLabel.text = self.viewModel.formattedPrice
            self.rankLabel.text = self.viewModel.formattedRank
            self.changeLabel.text = self.viewModel.formattedChange
            self.detailLabel.text = details.description?.htmlToString // NOTE: Requires a String extension for HTML formatting
            
            // Set the change color
            let isPositive = Double(details.change ?? "0") ?? 0 >= 0
            self.changeLabel.textColor = isPositive ? .systemGreen : .systemRed
            
            self.updateFavoriteButton()
        }
        
        // Update the chart view
        viewModel.onHistoryUpdate = { [weak self] in
            self?.embedChartView()
        }
    }
    
    private func embedChartView() {
        // Remove existing hosted view before adding a new one
        chartHostView.subviews.forEach { $0.removeFromSuperview() }
        
        let chartView = CoinChartView(
            history: viewModel.coinHistory,
            color: viewModel.coinDetails?.color ?? ""
        )
        
        let hostingController = UIHostingController(rootView: chartView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Add as a child view controller
        addChild(hostingController)
        chartHostView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Constraints to fill the host view
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: chartHostView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: chartHostView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: chartHostView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: chartHostView.bottomAnchor),
            
            // Give the host view a height constraint if needed, but the SwiftUI view
            // has a frame(height: 200) which should suffice.
            chartHostView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func timePeriodChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let period = TimePeriod.allCases[selectedIndex]
        
        Task {
            // Fetch new history data when the segment changes
            await viewModel.fetchCoinHistory(for: period)
        }
    }
    
    @objc private func toggleFavorite() {
        viewModel.toggleFavoriteStatus()
    }
    
    private func updateFavoriteButton() {
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
    }
}

// NOTE: CoinRanking's description is often HTML, requiring this extension.
extension String {
    var htmlToString: String {
        guard let data = data(using: .utf8) else { return self }
        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            ).string
        } catch {
            return self
        }
    }
}
