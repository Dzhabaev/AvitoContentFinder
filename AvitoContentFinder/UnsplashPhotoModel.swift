//
//  UnsplashPhotoModel.swift
//  AvitoContentFinder
//
//  Created by Chingiz on 08.09.2024.
//

import Foundation

// MARK: - UnsplashPhotoModel

struct UnsplashPhotoModel: Codable {
    let id: String
    let description: String?
    let urls: Urls
    let user: User
}

struct Urls: Codable {
    let regular: String
    let full: String
}

struct User: Codable {
    let name: String
}
