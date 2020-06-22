//
//  NetworkService.swift
//  GitHubClient
//
//  Created by usr01 on 19.06.2020.
//  Copyright © 2020 bhdn. All rights reserved.
//

import Foundation

class NetworkService {
    
    let baseUrl: String? = ""
    var querry: String = "?q=tetris&sort=stars&order=desc"
    
    enum networkResult: Swift.Error {
        case noValidUrl
        case wrongPath
        case noData
        case errorOccured
        case unknownError
    }
//
//    static func performRequest(querry: String? , cahcePolicy: URLRequest.CachePolicy, completion: @escaping (Result<Data, Error>) -> Void)  {
//
//        let baseUrl: String = "https://api.github.com/search/repositories"
//        let querry: String = "?q=tetris&sort=stars&order=desc"
//        let urlString = "\(baseUrl)\(querry)"
////            else {
////            completion(.failure(networkResult.wrongPath))
////            return
////        }
//        guard let url = URL(string: urlString) else {
//            completion(.failure(networkResult.noValidUrl))
//            return
//        }
//        let session = URLSession.shared
//
//
//        var request = URLRequest(url: url, cachePolicy: cahcePolicy, timeoutInterval: 10)
//
//        request.httpMethod = "GET"
//
//        print(url)
//
//
//        let dataTask = session.dataTask(with: request) {  data, response, error in
//            if let error = error {
//                completion(.failure(error))
//            }  else if let data = data {
//                DispatchQueue.main.async {
//                    completion(.success(data))
//                    completion(.success(<#T##Data#>))
//                }
//            } else {
//                completion(.failure(networkResult.unknownError))
//            }
//        }
//        dataTask.resume()
//
//    }
//
    
    static func performRequest(querry: String? , cahcePolicy: URLRequest.CachePolicy, completion: @escaping (Result<Data, Error>) -> Void)  {
            
            let baseUrl: String = "https://api.github.com/search/repositories"
            let querry: String = "?q=tetris&sort=stars"
            let urlString = "\(baseUrl)\(querry)"
    //            else {
    //            completion(.failure(networkResult.wrongPath))
    //            return
    //        }
            guard let url = URL(string: urlString) else {
                completion(.failure(networkResult.noValidUrl))
                return
            }
            let session = URLSession.shared
            

            var request = URLRequest(url: url, cachePolicy: cahcePolicy, timeoutInterval: 10)

            request.httpMethod = "GET"
            
            print(url)
            
            
            let dataTask = session.dataTask(with: request) {  data, response, error in
                if let error = error {
                    completion(.failure(error))
                }  else if let data = data {
                    DispatchQueue.main.async {
                        completion(.success(data))
    
                    }
                } else {
                    completion(.failure(networkResult.unknownError))
                }
            }
            dataTask.resume()
            
        }
    
}


extension URLSession {
    fileprivate func codableTask<T: Decodable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }

    func searchInfoModelTask(with url: URL, completionHandler: @escaping (SearchInfoModel?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}
