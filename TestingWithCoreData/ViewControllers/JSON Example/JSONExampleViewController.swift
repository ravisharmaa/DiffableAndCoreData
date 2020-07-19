//
//  JsonExampleViewController.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/19/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit
import CoreData

class JSONExampleViewController: UITableViewController {
    
    
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
    
    var companies: [CompanyEntity] = [CompanyEntity]()
    
    var dataSource: UITableViewDiffableDataSource<TableSection, CompanyEntity>!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureNavigationBar(title: "JSON & Core Data")
        
        view.backgroundColor = .darkBlue
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: "reuseMe")
        
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "Check For Update", style: .done, target: self, action: #selector(checkUpdate)),
            UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(handleDelete)),
        ]
        
        configureDataSource()
        configureSnapshot()
        
        do {
            try  fetchedResultsController.performFetch()
            
            guard let companies = fetchedResultsController.fetchedObjects else { return }
            
            self.companies = companies
            
            if companies.count <= 0 {
                
                //                NetworkManager.shared.fetch(object: [Company].self) { [weak self ] (response) in
                //
                //                    switch response {
                //
                //                    case .success(let companies):
                //                        self?.saveToCoreData(companies)
                //                    case .failure(let error):
                //                        print(error)
                //                    }
                //                }
                
                Reader.shared.read(from: "InitialData", fileExtension: .json, responsible: [Company].self) { [weak self] (response) in
                    switch response {
                    
                    case .success(let companies):
                        self?.saveToCoreData(companies)
                    case .failure(let error):
                        print(error)
                    }
                }
                
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        
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
            
            self.companies = fetchedResultsController.fetchedObjects ?? []
            
            snapshot.appendItems( self.companies)
            
            dataSource.apply(snapshot, animatingDifferences: true)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func saveToCoreData(_ companies: [Company]) {
        
        let privateContext = CoreDataManager.shared.privateContext
        
        privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
        
        companies.forEach { (company) in
            let entity = CompanyEntity(context: privateContext)
            entity.name = company.name
            entity.id = company.id!
        }
        
        do {
            
            try privateContext.save()
            try privateContext.parent?.save()
            
            DispatchQueue.main.async {
                self.configureSnapshot()
            }
            
        } catch let error {
            print(error)
        }
    }
}

extension JSONExampleViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        configureSnapshot()
    }
}

extension JSONExampleViewController {
    
    @objc func handleDelete() {
        CoreDataManager.shared.batchDelete(object: CompanyEntity.self)
        
        var snapshot = dataSource.snapshot()
        
        snapshot.deleteItems(self.companies)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    
    @objc func checkUpdate() {
        
        Reader.shared.read(from: "Updated", fileExtension: .json, responsible: [Company].self) { (response) in
            switch response {
            
            case .success:
                
                let privateContext = CoreDataManager.shared.privateContext
                privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
                let request = CoreDataManager.shared.getRequestObject(object: CompanyEntity.self)
                do {
                    let _ = try privateContext.fetch(request)
                    
                   
                    do {
                        try privateContext.save()
                        DispatchQueue.main.async { [weak self ] in
                            do {
                                let context = CoreDataManager.shared.persistentContainer.viewContext
                                if context.hasChanges {
                                    
                                    try context.save()
                                    
                                    var snapshot = self?.dataSource.snapshot()
                                    snapshot?.reloadSections([.main])
                                    self?.dataSource.apply(snapshot!, animatingDifferences: false)
                                }
                            } catch let error {
                                print(error.localizedDescription)
                            }
                            
                        }
                    } catch let error {
                        print("save error", error)
                    }
                } catch let error {
                    print(error)
                }
                
                
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
