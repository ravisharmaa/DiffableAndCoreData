//
//  FetchedResultsController.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/18/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit
import CoreData

class FetchedResultsController: UITableViewController {
    
    enum TableSection {
        case main
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<CompanyEntity> = {
        
        let request = CoreDataManager.shared.getRequestObject(object: CompanyEntity.self)
        
        request.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        
        controller.delegate = self
        return controller
    }()
    
    
    var dataSource: UITableViewDiffableDataSource<TableSection, CompanyEntity>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .darkBlue
        
        configureNavigationBar(title: "Fetched Results")
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "reuseMe")
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd)),
            UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleDelete)),
        ]
        
        configureDataSource()
        
        configureSnapshot()
    }
    
    func configureDataSource() {
        
        dataSource = .init(tableView: tableView, cellProvider: { (tableView, indexPath, company) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseMe",for: indexPath) as? CompanyCell
            
            cell?.company = company
            
            return cell
        })
    }
    
    func configureSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<TableSection, CompanyEntity>()
        
        do {
            try fetchedResultsController.performFetch()
            
            snapshot.appendSections([.main])
            
            snapshot.appendItems(fetchedResultsController.fetchedObjects ?? [])
            
            dataSource.apply(snapshot)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension FetchedResultsController {
    
    @objc func handleAdd() {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let company = CoreDataManager.shared.getObjectForContext(entityObject: CompanyEntity.self)
        
        company?.name = "Microsoft"
        
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func handleDelete() {
       
        let request = CoreDataManager.shared.getRequestObject(object: CompanyEntity.self)
        
        request.predicate = NSPredicate(format: "name CONTAINS %@", "G")
        
        do {
            let predicatedObjects = try CoreDataManager.shared.persistentContainer.viewContext.fetch(request)
            
            predicatedObjects.forEach { (entity) in
                CoreDataManager.shared.deleteObject(object: entity.self)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension FetchedResultsController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        configureSnapshot()
    }
}
