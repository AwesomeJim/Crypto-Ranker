//
//  CoinListViewController.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 01/11/2025.
//

import UIKit
import Kingfisher
import SwiftUI


final class CoinListViewController: UIViewController {
    
    // MARK: - Properties
    
    // MARK: Dependencies
    private var viewModel: CoinListViewModel!
    private var detailFactory: DetailFactoryProtocol!
    
    // MARK: UI Components
    @IBOutlet weak var tableView: UITableView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Initialization (Dependency Injection)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Inject dependencies here since we are loading from Storyboard
        let networkService = NetworkService()
        let favoritesManager = FavoritesManager.shared
        
        // Initialize the ViewModel property
        self.viewModel = CoinListViewModel(networkService: networkService, favoritesManager: favoritesManager)
        self.detailFactory = CoinDetailFactory(
            networkService: networkService,
            favoritesManager: favoritesManager
        )
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupTableView()
        setupNavigationBar()
        setupActivityIndicator()
        bindViewModel()
        
        // Start the initial data fetch
        Task { await viewModel.fetchNextPage() }
    }
    
    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CoinTableViewCell.self, forCellReuseIdentifier: "CoinCell")
        tableView.separatorStyle = .none // Remove default separators for the card look
        tableView.backgroundColor = .clear
        
    }
}


extension CoinListViewController {
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
}

extension CoinListViewController: UITableViewDataSource, UITableViewDelegate{
    
    // ViewModel Binding (How we receive updates)
    private func bindViewModel() {
        // The ViewModel calls this closure whenever currentCoins is updated
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            
            // The ViewModel updates the currentCoins array.
            // We now tell the UITableView to refresh its data based on the updated array.
            self.tableView.reloadData()
            
            // We can stop the indicator *after* the first data load
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.currentCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. Dequeue the custom cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell", for: indexPath) as? CoinTableViewCell else {
            return UITableViewCell()
        }
        
        let coin = viewModel.currentCoins[indexPath.row]
        cell.configure(with: coin)
        
        return cell
    }
    
    // MARK: - Delegate (Pagination and Navigation)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90 // Increase height to accommodate the chart and padding
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Pagination logic remains the same
        let coinCount = viewModel.currentCoins.count
        if indexPath.row >= coinCount - 5 {
            Task { await viewModel.fetchNextPage() }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCoin = viewModel.currentCoins[indexPath.row]
        print("Tapped coin: \(selectedCoin.name)")
        let coinUUID =  selectedCoin.uuid
        
        guard let detailVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CoinDetail") as? CoinDetailViewController
        else { return }
        
        // 1. Use the factory to create the ViewModel
        let detailViewModel = detailFactory.makeDetailViewModel(for: coinUUID)
        // 2. Inject the ViewModel into the VC property
        detailVC.viewModel = detailViewModel
        
        // 3. Push the fully configured View Controller
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Swipe Actions (Favorites)
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.currentCoins[indexPath.row]
        let isFavorite = viewModel.isFavorite(coin: coin)
        
        let action = UIContextualAction(style: isFavorite ? .destructive : .normal, title: isFavorite ? "Unfavorite" : "Favorite") { [weak self] (_, _, completionHandler) in
            self?.viewModel.toggleFavoriteStatus(for: coin)
            
            // Reload the specific row to update the swipe action and potentially the favorite star
            tableView.reloadRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        action.image = isFavorite ? UIImage(systemName: "trash.fill") : UIImage(systemName: "heart.fill")
        action.backgroundColor = isFavorite ? .systemRed: .systemGreen
        return UISwipeActionsConfiguration(actions: [action])
    }
}


extension CoinListViewController {
    
    private func setupNavigationBar() {
        let filterButton = UIBarButtonItem(title: "Filter", image: UIImage(systemName: "slider.horizontal.3"), primaryAction: nil, menu: makeFilterMenu())
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func makeFilterMenu() -> UIMenu {
        let actions: [UIAction] = CoinFilter.allCases.map { filter in
            return UIAction(title: filter.title, handler: { [weak self] _ in
                self?.viewModel.applyFilter(filter)
            })
        }
        return UIMenu(title: "Sort By", children: actions)
    }
    
}
