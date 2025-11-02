//
//  FavoritesViewController.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import UIKit

final class FavoritesViewController: UIViewController{

    // MARK: - Properties
    private var viewModel: FavoritesViewModel! // <-- Uses the new ViewModel
    // MARK: UI Components
    @IBOutlet weak var tableView: UITableView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // 🔑 Inject dependencies here if loading from Storyboard
        let networkService = NetworkService()
        let favoritesManager = FavoritesManager.shared
        
        // Initialize the ViewModel property
        self.viewModel = FavoritesViewModel(networkService: networkService, favoritesManager: favoritesManager)
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure data is fresh when the screen appears
        Task { await viewModel.fetchFavoriteCoins() }
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CoinTableViewCell.self, forCellReuseIdentifier: "CoinCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        
        // Setup activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }
    
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.favoriteCoins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CoinCell", for: indexPath) as? CoinTableViewCell else {
            return UITableViewCell()
        }
        let coin = viewModel.favoriteCoins[indexPath.row]
        cell.configure(with: coin)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCoin = viewModel.favoriteCoins[indexPath.row]
        // TODO: Push to CoinDetailViewController (Same as Screen 1)
        print("Tapped favorite coin: \(selectedCoin.name)")
    }
    
    // Implement swipe-to-remove here
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.favoriteCoins[indexPath.row]
        
        let removeAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (_, _, completion) in
            // Unfavorite the coin
            self?.viewModel.toggleFavoriteStatus(for: coin)
            
            // The notification observer in the ViewModel will trigger a refetch and reload
            completion(true)
        }
        
        removeAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}
