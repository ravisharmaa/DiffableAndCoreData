//
//  Company.swift
//  CoreData
//
//  Created by Ravi Bastola on 7/15/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import Foundation

struct Company: Codable, Hashable {
    
    let name: String?
    
    let identifier = UUID()
    
    let founded: Date?
}
