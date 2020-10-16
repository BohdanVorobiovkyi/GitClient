//
//  NetworkService.swift
//  GitHubClient
//
//  Created by usr01 on 19.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

class NetworkService {
    
    static let baseUrl: String = "https://api.github.com/search/repositories"
//    var querry: String = "?q=tetris&sort=stars&order=desc"
    
    enum NetworkResult: Swift.Error {
        case noValidUrl
        case wrongPath
        case noData
        case errorOccured
        case unknownError
    }
    
     static func performRequest(querry: String?, page: Int , cahcePolicy: URLRequest.CachePolicy, completion: @escaping (Result<Data, Error>) -> Void)  {
        
        let baseUrl: String = NetworkService.baseUrl
        guard let searchRepo = querry else {return}
        let querry: String = "?q=\(searchRepo)&sort=stars&per_page=30&page=\(page)"
        let urlString = "\(baseUrl)\(querry)".encodeUrl
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkResult.noValidUrl))
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: cahcePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
  
        let dataTask = session.dataTask(with: request) {  data, response, error in
            if let error = error {
                completion(.failure(error))
            }  else if let data = data {
                 completion(.success(data))
            } else {
                completion(.failure(NetworkResult.unknownError))
            }
        }
        dataTask.resume()
    }
}
