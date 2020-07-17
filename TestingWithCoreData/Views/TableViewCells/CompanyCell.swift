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
    
    
    fileprivate lazy var companyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "imagePlaceholder"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        return imageView
    }()
    
    fileprivate lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var company: CompanyEntity? {
        didSet {
            
            if let name = company?.name, let founded = company?.foundedDate, let image = company?.image  {
                
                let formatter = DateFormatter()
                
                formatter.dateFormat = "MMM dd, yyyy"
                
                let foundedString = formatter.string(from: founded)
                
                self.companyNameLabel.text = name + " - " + foundedString
                
                self.companyImageView.image = UIImage(data: image)
                
            } else {
                self.companyNameLabel.text = company?.name
                self.companyImageView.image = UIImage(named: "imagePlaceholder")
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .tealColor
        
        textLabel?.textColor = .systemBackground
        textLabel?.font = .boldSystemFont(ofSize: 17)
        
        addSubview(companyImageView)
        addSubview(companyNameLabel)
        
        
        NSLayoutConstraint.activate([
            companyImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            companyImageView.heightAnchor.constraint(equalToConstant: 50),
            companyImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            companyImageView.widthAnchor.constraint(equalToConstant: 50),
            
            companyNameLabel.leadingAnchor.constraint(equalTo: companyImageView.trailingAnchor, constant: 10),
            companyNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
            
        ])
        
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
