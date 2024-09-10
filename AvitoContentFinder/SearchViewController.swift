//
//  SearchViewController.swift
//  AvitoContentFinder
//
//  Created by Chingiz on 08.09.2024.
//

import UIKit

// MARK: - SearchViewController

final class SearchViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let service = UnsplashService()
    private var photos: [UnsplashPhotoModel] = []
    private let historyManager = SearchHistoryManager()
    private var filteredHistory: [String] = []
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.createFlowLayout(
            viewWidth: UIScreen.main.bounds.width,
            numberOfItemsInRow: 2,
            padding: 16,
            interItemSpacing: 16
        )
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        collectionView.register(
            PhotoCell.self,
            forCellWithReuseIdentifier: PhotoCell.reuseIdentifier
        )
        tableView.register(
            UITableViewCell.self, forCellReuseIdentifier: "historyCell"
        )
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = UIColor.white
        
        [searchBar,
         collectionView,
         tableView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        searchBar.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "Ок",
                style: .default
            )
        )
        present(alertController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        let photo = photos[indexPath.item]
        cell.configure(with: photo)
        return cell
    }
}

// MARK: - UICollectionViewFlowLayout

extension UICollectionViewFlowLayout {
    
    static func createFlowLayout(viewWidth: CGFloat, numberOfItemsInRow: CGFloat, padding: CGFloat, interItemSpacing: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let totalPadding = padding * 2 + (numberOfItemsInRow - 1) * interItemSpacing
        let itemWidth = (viewWidth - totalPadding) / numberOfItemsInRow
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = interItemSpacing
        layout.minimumLineSpacing = interItemSpacing
        layout.sectionInset = UIEdgeInsets(top: 16, left: padding, bottom: 16, right: padding)
        return layout
    }
}


// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let history = historyManager.getHistory()
        filteredHistory = history.filter { $0.lowercased().contains(searchText.lowercased()) }
        tableView.isHidden = filteredHistory.isEmpty
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        historyManager.saveQuery(query)
        service.searchPhotos(query: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let photos):
                    self.photos = photos
                    self.collectionView.reloadData()
                case .failure(let error):
                    self.showErrorAlert(message: "Не удалось загрузить данные: \(error.localizedDescription)")
                }
            }
        }
        tableView.isHidden = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        cell.textLabel?.text = filteredHistory[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuery = filteredHistory[indexPath.row]
        searchBar.text = selectedQuery
        searchBarSearchButtonClicked(searchBar)
    }
}
