//
//  NetworkManager.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/19/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import Foundation

protocol Networking {
    
    var path: String { get }
}

extension Networking {
    
    var path: String {
        return "https://api.letsbuildthatapp.com/intermediate_training/companies"
    }
    
}

enum StatusCode: Int {
    case Success = 200
}

enum NetworkingError: Error, CustomStringConvertible {
    
    case BadURL
    case ResponseError
    case StatusError
    case InvalidData
    
    var description: String {
        
        switch self {
        
        case .BadURL:
            return "Whoops!, Cannot Parse the URL."
        
        case .ResponseError:
            return "Went to the network but could not get the response."
        
        case .StatusError:
            return "Went to the network but could not get the response, because the status code was not ok."
            
        case .InvalidData:
            return "Went to the network but got the response, but the data was not ok."
        }
    }
}

struct NetworkManager: Networking {
    
    static let shared = NetworkManager()
    
    private init () {}
    
    func fetch <T: Codable> (object: T.Type, completion: @escaping(Result<T, NetworkingError>) -> Void) {
        
        guard let url = URL(string: path) else {
            completion(.failure(.BadURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.ResponseError))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == StatusCode.Success.rawValue else {
                completion(.failure(.StatusError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.InvalidData))
                return
            }
            
            do {
                
                let response = try JSONDecoder().decode(T.self, from: data)
               
                completion(.success(response))
            
            } catch let error {
                
                print(error)
            }
            
            
            
        }.resume()
    }
}
