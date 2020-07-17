//
//  ViewController.swift
//  CoreData
//
//  Created by Ravi Bastola on 7/15/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class CompaniesController: UITableViewController {
    
    
    enum TableSection: CaseIterable {
        case main
    }
    
    var companies: [CompanyEntity] = [CompanyEntity]()
    
    var dataSource: DataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureNavigationBar()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Plus")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBarItemClicked))
        
        tableView.backgroundColor = .darkBlue
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: CompanyCell.reuseIdentifier)
        tableView.isUserInteractionEnabled = true
        
        
        fetchDataFromStorage()
        
        configureDataSource()
    }
    
    func fetchDataFromStorage() {
        
        let company = CoreDataManager.shared.fetch(entityObject: CompanyEntity.self, entityName: "CompanyEntity")
        
        if let company = company {
            self.companies = company
        }
    }
    
    
    func configureDataSource() {
        
        
        dataSource = .init(tableView: tableView, cellProvider: { (tableView, indexPath, company) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyCell.reuseIdentifier, for: indexPath) as? CompanyCell else {
                assert(false)
            }
            cell.textLabel?.text = company.name
            
            return cell
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<TableSection, CompanyEntity>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(companies)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteHandler: UIContextualAction.Handler = { [weak self] _, _, completion in
            let item = self?.dataSource.itemIdentifier(for: indexPath)
            
            var snapshot = self?.dataSource.snapshot()
            
            snapshot?.deleteItems([item!])
            
            self?.dataSource.apply(snapshot!, animatingDifferences: true)
            
            CoreDataManager.shared.deleteObject(object: item!)
            
            completion(true)
        }
        
        
        let editHandler: UIContextualAction.Handler = { _, _, completion in
            completion(true)
        }
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete", handler: deleteHandler)
        
        let editAction = UIContextualAction(style: .normal, title: "Edit", handler: editHandler)
        
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    
    // MARK:- Must Add Custom DataSource Class To Enable Editing
    
    class DataSource: UITableViewDiffableDataSource<TableSection, CompanyEntity> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    }
}


extension CompaniesController {
    
    @objc func handleBarItemClicked() {
        
        let controller = CreateCompanyController()
        
        controller.didTapCancelButton = { [weak self] companyEntity in
            
            var snapshot = self?.dataSource.snapshot()
            
            snapshot?.appendItems([companyEntity!], toSection: .main)
            
            self?.dataSource.apply(snapshot!, animatingDifferences: true)
        }
        
        let createController = UINavigationController(rootViewController: controller)
        createController.modalPresentationStyle = .overFullScreen
        present(createController, animated: true, completion: nil)
    }
}

