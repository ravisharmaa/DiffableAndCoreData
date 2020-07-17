//
//  CompanyCell.swift
//  CoreData
//
//  Created by Ravi Bastola on 7/15/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit

class CompanyCell: UITableViewCell {
    
    static let reuseIdentifier = "reuseMe"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .tealColor
        
        textLabel?.textColor = .systemBackground
        textLabel?.font = .boldSystemFont(ofSize: 17)
        
        isUserInteractionEnabled = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
