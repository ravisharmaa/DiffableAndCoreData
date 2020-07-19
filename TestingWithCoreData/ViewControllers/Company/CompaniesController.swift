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

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
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
        
        configureNavigationBar(title: "Companies")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Plus")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBarItemClicked))
        
        navigationItem.leftBarButtonItems = [
            
            UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handleClearAll)),
            UIBarButtonItem(title: "Insert", style: .plain, target: self, action: #selector(insertInBackGroundThread)),
            UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(updateInBackground)),
            UIBarButtonItem(title: "Nested", style: .plain, target: self, action: #selector(nestedUpdate))
        ]
        
        tableView.backgroundColor = .darkBlue
        
        tableView.register(CompanyCell.self, forCellReuseIdentifier: CompanyCell.reuseIdentifier)
        tableView.isUserInteractionEnabled = true
        
        fetchDataFromStorage()
        configureDataSource()
    }
    
    func fetchDataFromStorage() {
        
        let company = CoreDataManager.shared.fetch(entityObject: CompanyEntity.self)
        
        if let company = company {
            self.companies = company
        }
    }
    
    
    func configureDataSource() {
        
        dataSource = .init(tableView: tableView, cellProvider: { (tableView, indexPath, company) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CompanyCell.reuseIdentifier, for: indexPath) as? CompanyCell else {
                assert(false)
            }
            
            
            cell.company = company
            
            return cell
        })
        
        
        var snapshot = NSDiffableDataSourceSnapshot<TableSection, CompanyEntity>()
        snapshot.appendSections([.main])
        
        snapshot.appendItems(companies)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // MARK:- Must Add Custom DataSource Class To Enable Editing
    
    class DataSource: UITableViewDiffableDataSource<TableSection, CompanyEntity> {
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    }
}


extension CompaniesController {
    
    @objc fileprivate func handleBarItemClicked() {
        
        let controller = CreateCompanyController()
        
        controller.didTapCreateButton = { [weak self] companyEntity in
            
            var snapshot = self?.dataSource.snapshot()
            
            snapshot?.appendItems([companyEntity!], toSection: .main)
            
            self?.dataSource.apply(snapshot!, animatingDifferences: true)
        }
        
        let createController = UINavigationController(rootViewController: controller)
        createController.modalPresentationStyle = .overFullScreen
        present(createController, animated: true, completion: nil)
    }
    
    @objc fileprivate func handleClearAll() {
        
        var snapshot = dataSource.snapshot()
        
        if self.companies.isEmpty {
            
            guard let company = CoreDataManager.shared.fetch(entityObject: CompanyEntity.self) else { return }
            snapshot.deleteItems(company)
            
        } else {
            snapshot.deleteItems(self.companies)
        }
        
        CoreDataManager.shared.batchDelete(object: CompanyEntity.self)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func insertInBackGroundThread() {
        
        //        DispatchQueue.global(qos: .background).async {
        //
        //            // creating core data object in background thread produces crashes
        //            let context = CoreDataManager.shared.persistentContainer.viewContext
        //            (0...10).forEach { (value) in
        //                let company = CompanyEntity(context: context)
        //                company.name = "\(value)"
        //            }
        //
        //            do {
        //                try context.save()
        //            } catch let error {
        //                print(error)
        //            }
        //        }
        
        
        /// ```performBackgroundTask```  executes the task in background thread.
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (context) in
            
            /// 1. This loops only adds 10 items iteratively into the core data object
            (0...10).forEach { (value) in
                let company = CompanyEntity(context: context)
                company.name = "\(value)"
            }
            
            do {
                try context.save()
            } catch let error {
                print(error)
            }
            
            DispatchQueue.main.async { [weak self] in
                
                /// 2. Need to clear any lingering data from the source
                self?.companies = []
                
                /// 3. Fetch the recently created data
                self?.fetchDataFromStorage()
                
                
                /// 4. In this particular example the snapshot was already created so ```configureDataSource()``` simply adding this method won't work because the number of sections and item will conflict, as in the
                /// ```configureMethod``` we don't check whether the section is already added or not or whether items are already available or not.
                
                var snapshot = self?.dataSource.snapshot()
                
                /// 5. ```deleteAllItems()``` deletes the section and items as well so call to ```snapshot.deleteSection()``` is not needed.
                snapshot?.deleteAllItems()
                
                /// 6. Regular work of updating the datasource.
                snapshot?.appendSections([.main])
                
                if let company = self?.companies {
                    snapshot?.appendItems(company)
                }
                
                /// 7. Applying the snapshot.
                self?.dataSource.apply(snapshot!)
                
            }
        }
    }
    
    
    @objc func updateInBackground() {
        
        CoreDataManager.shared.persistentContainer.performBackgroundTask { (backContext) in
            
            let request = CoreDataManager.shared.getRequestObject(object: CompanyEntity.self)
            
            do {
                let companies = try backContext.fetch(request)
                
                companies.forEach({$0.name = "B: \($0.name ?? "")"})
                
            } catch let error {
                print(error.localizedDescription)
            }
            
            
            do {
                try backContext.save()
                
                DispatchQueue.main.async { [weak self ] in
                   
                    self?.fetchDataFromStorage()
                    
                    var snapshot = self?.dataSource.snapshot()
                    
                    /// 5. ```deleteAllItems()``` deletes the section and items as well so call to ```snapshot.deleteSection()``` is not needed.
                    snapshot?.deleteAllItems()
                    
                    /// 6. Regular work of updating the datasource.
                    
                    snapshot?.appendSections([.main])
                    
                    if let company = self?.companies {
                        snapshot?.appendItems(company)
                    }
                    
                    /// 7. Applying the snapshot.
                    
                    self?.dataSource.apply(snapshot!)
                }
                
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
    }
    
    @objc func nestedUpdate() {
        
        /// 1. Need to have a private context to have a nested update.
        
        let privateContext = CoreDataManager.shared.privateContext
        
        /// 2. Every private context needs to set a parent context which refers the main context
        privateContext.parent = CoreDataManager.shared.persistentContainer.viewContext
        /// 3. Initiate a request
        let request = CoreDataManager.shared.getRequestObject(object: CompanyEntity.self)
        
        /// 4. Set a fetch limit.
        request.fetchLimit = 2
        
        do {
            /// 5. Fetch the context from the private perspective
            
            let companies = try privateContext.fetch(request)
            
            /// 6. Update the data set fetched from the private context
            
            companies.forEach { (company) in
                company.name = "F: \(company.name ?? "")"
            }
            
            do {
                
                /// 7. Saving the private context.
                try privateContext.save()
                
                ///8. Hopping into the main thread.
                
                DispatchQueue.main.async { [weak self ] in
                    
                    do {
                        /// 9. We need the ```viewContext``` to reflect the changes from the child context(Fresh Context)
                        
                        let context = CoreDataManager.shared.persistentContainer.viewContext
                        
                        /// 10. Core Data suggests that it is better to check the if there are changes or not.
                        
                        if context.hasChanges {
                            
                            /// 11. Finally save the recent data.
                            try context.save()
                            
                            var snapshot = self?.dataSource.snapshot()
                            
                            /// 12. Allowing the section to reload the selected section only reflects the desired changes.
                            
                            snapshot?.reloadSections([.main])
                            
                            /// 13. Finally the dance of applying the snapshot.
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
    }
}

