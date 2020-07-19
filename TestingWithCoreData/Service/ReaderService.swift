//
//  ReaderService.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/19/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import Foundation


enum FileExtensions: String, CustomStringConvertible {
    case json
    case text
    
    var description: String {
        switch self {
        case .json:
            return "json"
        default:
            return "txt"
        }
    }
}

struct Reader {
    
    static let shared = Reader()
    
    private init () {}
        
    func read<T: Codable>(from path: String, fileExtension: FileExtensions, responsible: T.Type, completion: @escaping ((Result<T, Error>) -> ())) {
        
        let file = Bundle.main.path(forResource: path, ofType: fileExtension.description)
        
        do {
            let file = try String(contentsOfFile: file!).data(using: .utf8)
            let data = try JSONDecoder().decode(T.self, from: file!)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
}
