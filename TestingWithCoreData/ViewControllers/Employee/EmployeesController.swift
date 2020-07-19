//
//  EmployeesController.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/17/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit


class EmployeesController: UITableViewController {
    
    let company: CompanyEntity
    
    var dataSource: DataSource!
    
    var employees: [Employee] = [Employee]()
    
    enum TableSection: Int, CustomStringConvertible, CaseIterable {
        case main
        case second
        case third
        
        var description: String {
            switch self {
            case .main:
                return "BOD"
            case .second:
                return "Management"
            case .third:
                return "Staff"
                
            }
        }
    }
    
    init(company: CompanyEntity) {
        self.company = company
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Plus"), style: .plain, target: self, action: #selector(handleAdd))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseMe")
        
        tableView.tableFooterView = UIView()
        
        tableView.backgroundColor = .darkBlue
        
        if let employees = company.employees?.allObjects as? [Employee] {
            self.employees = employees
        }
        
        configureDataSource()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = company.name
    }
    
    func configureDataSource() {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MMM dd, yyyy"
        
        dataSource = .init(tableView: tableView, cellProvider: { (tableView, indexPath, employee) -> UITableViewCell? in
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseMe", for: indexPath)
            
            cell.backgroundColor = .tealColor
            
            if let joined = employee.employeeInfo?.joinedDate {
                let joinedString = formatter.string(from: joined)
                cell.textLabel?.text = "\(employee.name ?? "") | Joined: \(joinedString)"
            } else {
                cell.textLabel?.text = employee.name
            }
            
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            cell.textLabel?.textColor = .systemBackground
            
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<TableSection, Employee>()
        
        let bodEmployees = employees.filter({$0.role == "BOD"})
        
        let managementEmployees = employees.filter({$0.role == "Management"})
        
        let staffEmployees = employees.filter({$0.role == "Staff"})
        
        TableSection.allCases.forEach { (section) in
            snapshot.appendSections([section])
            switch section {
            case .main:
                snapshot.appendItems(bodEmployees, toSection: .main)
            case .second:
                snapshot.appendItems(managementEmployees, toSection: .second)
            default:
                snapshot.appendItems(staffEmployees, toSection: .third)
            }
            
        }
        dataSource.apply(snapshot, animatingDifferences: true)
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
        
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete", handler: deleteHandler)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .lightBlue
        
        let label = UILabel()
        
        let tableSection = TableSection(rawValue: section)
        
        label.text = tableSection?.description
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    class DataSource: UITableViewDiffableDataSource<TableSection, Employee> {
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    }
    
}

extension EmployeesController {
    
    @objc func handleAdd() {
        
        let createEmployeeController = CreateEmployeeController(company: company)
        
        createEmployeeController.didTapCreateButton = { [weak self] createdEmployee in
            
            var snapshot = self?.dataSource.snapshot()
            
            if TableSection.main.description == createdEmployee?.role {
                snapshot?.appendItems([createdEmployee!], toSection: .main)
            }
            
            if TableSection.second.description == createdEmployee?.role {
                snapshot?.appendItems([createdEmployee!], toSection: .second)
            }
            
            if TableSection.third.description == createdEmployee?.role {
                snapshot?.appendItems([createdEmployee!], toSection: .third)
            }
            
            self?.dataSource.apply(snapshot!, animatingDifferences: true)
        }
        
        createEmployeeController.modalPresentationStyle = .fullScreen
        
        let controller = UINavigationController(rootViewController: createEmployeeController)
        
        present(controller, animated: true, completion: nil)
    }
}
