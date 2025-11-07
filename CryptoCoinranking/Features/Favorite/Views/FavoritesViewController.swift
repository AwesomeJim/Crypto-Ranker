//
//  FavoritesViewController.swift
//  CryptoCoinranking
//
//  Created by Awesome Jim on 02/11/2025.
//

import UIKit
import SwiftUI
internal import Combine

final class FavoritesViewController: UIViewController{
    
    // MARK: - Properties
    private var viewModel: FavoritesViewModel!
    private var detailFactory: DetailFactoryProtocol!
    
    //Store Combine subscriptions here
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: UI Components
    @IBOutlet weak var tableView: UITableView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // Add the hosting controller for the SwiftUI empty state
    private lazy var emptyStateHost = UIHostingController(rootView: EmptyFavoritesView())
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // We Inject dependencies since we are loading from Storyboard
        let networkService = NetworkService()
        let favoritesManager = FavoritesManager.shared
        
        // Initialize the ViewModel property
        self.viewModel = FavoritesViewModel(networkService: networkService, favoritesManager: favoritesManager)
        self.detailFactory = CoinDetailFactory(
            networkService: networkService,
            favoritesManager: favoritesManager
        )
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
        
        addChild(emptyStateHost)
        view.addSubview(emptyStateHost.view)
        emptyStateHost.didMove(toParent: self)
        
        // Setup constraints for the empty state to fill the view
        emptyStateHost.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateHost.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateHost.view.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emptyStateHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
        
        // Start hidden
         emptyStateHost.view.isHidden = true
    }
    
    private func bindViewModel() {
        //
        viewModel.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            //
            let isEmpty = self.viewModel.favoriteCoins.isEmpty
            print("Favorite Coins \(isEmpty)")
            self.emptyStateHost.view.isHidden = !isEmpty
            
            self.tableView.reloadData()
        }
        //
        viewModel.$appError
            .compactMap { $0 } // Only proceed if error is not nil
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.presentErrorAlert(error: error)
                self?.viewModel.appError = nil // Clear the error after showing
            }
            .store(in: &cancellables)
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
        let coinUUID =  selectedCoin.uuid
        print("Tapped favorite coin: \(selectedCoin.name)")
        guard let detailVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CoinDetail") as? CoinDetailViewController
        else { return }
        
    
        let detailViewModel = detailFactory.makeDetailViewModel(for: coinUUID)
        detailVC.viewModel = detailViewModel
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // swipe-to-remove here
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = viewModel.favoriteCoins[indexPath.row]
        
        let removeAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            // Unfavorite the coin
            self?.viewModel.toggleFavoriteStatus(for: coin)
            // The notification observer in the ViewModel will trigger a refetch and reload
            completion(true)
        }
        removeAction.image = UIImage(systemName: "trash.fill")
        removeAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}
