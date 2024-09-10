//
//  UnsplashService.swift
//  AvitoContentFinder
//
//  Created by Chingiz on 08.09.2024.
//

import Foundation

final class UnsplashService {
    private let accessKey = "sG3qXc7av5XKG9kGLbn52zXkJvLyqjl_QqafuylvlDY"
    private let baseUrl = "https://api.unsplash.com/"
    
    func searchPhotos(query: String, completion: @escaping (Result<[UnsplashPhotoModel], Error>) -> Void) {
        let urlString = "\(baseUrl)search/photos?query=\(query)&per_page=30&client_id=\(accessKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(result.results))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

struct SearchResult: Codable {
    let results: [UnsplashPhotoModel]
}
