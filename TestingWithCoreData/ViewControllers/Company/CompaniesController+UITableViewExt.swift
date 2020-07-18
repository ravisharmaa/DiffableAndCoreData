//
//  CompaniesController+UITableViewExt.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/17/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit


extension CompaniesController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightBlue
        
        let label = UILabel()
        label.text = "Company Names"
        
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { fatalError()}
        
        var snapshot = self.dataSource.snapshot()
        
        
        let deleteHandler: UIContextualAction.Handler = { [weak self] _, _, completion in
            
            snapshot.deleteItems([item])
            
            self?.dataSource.apply(snapshot, animatingDifferences: true)
            
            CoreDataManager.shared.deleteObject(object: item)
            
            completion(true)
        }
        
        
        let editHandler: UIContextualAction.Handler = { [weak self] _, _, completion in
            
            let editingController = CreateCompanyController()
            
            editingController.companyEntity = item
            
            
            editingController.didEndEditing = { [weak self] editedCompany in
                
                snapshot.reloadItems([editedCompany!])
                
                self?.dataSource.apply(snapshot)
            }
            
            
            let nav = UINavigationController(rootViewController: editingController)
            
            self?.present(nav, animated: true, completion: nil)
            
            completion(true)
        }
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete", handler: deleteHandler)
        
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: editHandler)
        
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        
        label.text = "No companies available"
        
        label.textAlignment = .center
        
        label.textColor = .systemGray
        return label
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return companies.count == 0 ? 150 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let controller = EmployeesController(company: item)
        
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    
}
