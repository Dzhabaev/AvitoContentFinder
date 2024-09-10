//
//  PhotoCell.swift
//  AvitoContentFinder
//
//  Created by Chingiz on 08.09.2024.
//

import UIKit

// MARK: - PhotoCell

final class PhotoCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "PhotoCell"
    
    // MARK: - Private Properties
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with photo: UnsplashPhotoModel) {
        descriptionLabel.text = photo.description ?? "No description"
        imageView.image = UIImage(systemName: "photo")
        activityIndicator.startAnimating()
        
        if let url = URL(string: photo.urls.regular) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    
                    if let data = data, error == nil, let image = UIImage(data: data) {
                        self.imageView.image = image
                    } else {
                        self.imageView.image = UIImage(systemName: "xmark.octagon")
                    }
                }
            }
            task.resume()
        } else {
            activityIndicator.stopAnimating()
            imageView.image = UIImage(systemName: "xmark.octagon")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        
        [imageView,
         descriptionLabel,
         activityIndicator
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}
