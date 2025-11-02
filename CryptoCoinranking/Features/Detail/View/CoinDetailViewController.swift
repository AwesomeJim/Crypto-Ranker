//
//  CoinDetailViewController.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//
import UIKit
import SwiftUI
internal import Combine

final class CoinDetailViewController: UIViewController {
    
    
    //Store Combine subscriptions here
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Dependencies
    var viewModel: CoinDetailViewModel!
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let timePeriodSegmentedControl = UISegmentedControl(items: TimePeriod.allCases.map { $0.title })
    private let detailLabel = UILabel()
    private let chartHostView = UIView() // Host for the SwiftUI Chart
    
    required init?(coder: NSCoder) {
        // Must call super.init(coder:) when loading from a Storyboard.
        super.init(coder: coder)
        //Hide the bottom tab bar when pushed onto the stack
        self.hidesBottomBarWhenPushed = true
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
        detailLabel.numberOfLines = 0
        
        // Replace UIKit summary with SwiftUI Header
        let headerHost = UIHostingController(rootView: CoinDetailHeaderView(viewModel: viewModel))
        
        // Add the header view
        stackView.addArrangedSubview(headerHost.view)
        headerHost.view.translatesAutoresizingMaskIntoConstraints = false
        headerHost.view.backgroundColor = .clear // Ensure transparent background
        
        // IMPORTANT: Make the hosting controller a child
        addChild(headerHost)
        headerHost.didMove(toParent: self)
        
        // Configure Segmented Control
        timePeriodSegmentedControl.selectedSegmentIndex = TimePeriod.allCases.firstIndex(of: viewModel.currentPeriod) ?? 0
        timePeriodSegmentedControl.addTarget(self, action: #selector(timePeriodChanged), for: .valueChanged)
        
        // Build the hierarchy
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)
        
        
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
        // 1. Subscription to coinHistory changes
        viewModel.$coinHistory
            .receive(on: DispatchQueue.main) // Ensure UI updates are on the main thread
            .sink { [weak self] _ in
                // This block is executed every time coinHistory changes (after a fetch or segment change)
                self?.embedChartView()
            }
            .store(in: &cancellables) // Store the subscription
        
        // 2. Subscription to static details (optional, as the SwiftUI header handles most of this)
        viewModel.$coinDetails
            .receive(on: DispatchQueue.main)
            .sink { [weak self] details in
                guard let self = self, let details = details else { return }
                
                self.navigationItem.title = details.name
                self.detailLabel.text = details.description?.htmlToString
                self.updateFavoriteButton()
            }
            .store(in: &cancellables)
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
        updateFavoriteButton()
    }
    
    private func updateFavoriteButton() {
        let imageName = viewModel.isFavorite ? "heart.fill" : "heart"
        let button = navigationItem.rightBarButtonItem
        //Set the tint color to green for visibility and positive action
        button?.tintColor = .systemGreen
        button?.image = UIImage(systemName: imageName)
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
