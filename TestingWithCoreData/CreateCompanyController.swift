//
//  CreateCompanyController.swift
//  CoreData
//
//  Created by Ravi Bastola on 7/16/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit
import CoreData

class CreateCompanyController: UIViewController {
    
    
    fileprivate lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var companyTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Name"
        return textField
    }()
    
    
    fileprivate lazy var backGroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .tealColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var didTapCreateButton: ((_ entity: CompanyEntity?)-> ())?
    
    var didEndEditing: ((_ entity: CompanyEntity?) -> ())?
    
    var companyEntity: CompanyEntity? {
        didSet {
            self.companyTextField.text = self.companyEntity?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureNavigationBar()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreate))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        view.addSubview(backGroundView)
        
        backGroundView.backgroundColor = .lightBlue
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backGroundView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        backGroundView.addSubview(companyNameLabel)
        
        backGroundView.addSubview(companyTextField)
        
        NSLayoutConstraint.activate([
            companyNameLabel.topAnchor.constraint(equalTo: view.topAnchor),
            companyNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            companyNameLabel.heightAnchor.constraint(equalToConstant: 50),
            companyNameLabel.widthAnchor.constraint(equalToConstant: 100),
            
            companyTextField.topAnchor.constraint(equalTo: companyNameLabel.topAnchor),
            companyTextField.leadingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            companyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            companyTextField.bottomAnchor.constraint(equalTo: companyNameLabel.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = companyEntity == nil ? "Create Company" : "Edit Company"
    }
    
    
}

extension CreateCompanyController {
    
    
    @objc func handleCreate() {
        
        if companyEntity == nil {
            handleSave()
        } else {
            handleEdit()
        }
    }
    
    func handleSave() {
        
        let company = CoreDataManager.shared.getObjectForContext(entityObject: CompanyEntity.self, entityName: "CompanyEntity")
        
        guard let text = companyTextField.text else { fatalError() }
        
        company?.setValue(text, forKey: "name")
        
        do {
            try CoreDataManager.shared.persistentContainer.viewContext.save()
            
            dismiss(animated: true) {
                self.didTapCreateButton?(company)
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        
    }
    
    func handleEdit() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        companyEntity?.name = companyTextField.text
        
        do {
            try context.save()
            dismiss(animated: true, completion: {
                self.didEndEditing?(self.companyEntity)
            })
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}
