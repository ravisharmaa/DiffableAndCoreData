//
//  UIViewController+Extension.swift
//  CoreData
//
//  Created by Ravi Bastola on 7/16/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit


extension UIViewController {
    
    func configureNavigationBar(title: String) {
        
        
        navigationController?.navigationBar.isTranslucent = false
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.title = title
        
        if #available(iOS 13.0, *) {
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithOpaqueBackground()
            navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navAppearance.backgroundColor = .systemRed
            navigationController?.navigationBar.standardAppearance = navAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navAppearance
            navigationController?.navigationBar.tintColor =  .systemBackground
        }
    }
}
