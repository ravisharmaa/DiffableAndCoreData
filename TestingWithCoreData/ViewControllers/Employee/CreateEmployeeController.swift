//
//  CreateEmployeeController.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/17/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import UIKit

class CreateEmployeeController: UIViewController {
    
    fileprivate lazy var employeeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate lazy var employeeNameTextField: UITextField = {
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
    
    fileprivate lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Joined Date"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    
    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["BOD","Management", "Staff"])
        control.selectedSegmentIndex = 0
        control.tintColor = .systemBlue
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    var didTapCreateButton: ((_ employee: Employee?) -> Void)?
    
    var company: CompanyEntity
    
    
    init(company: CompanyEntity) {
        self.company = company
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureNavigationBar(title: "Create Employee")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreate))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
        
        view.addSubview(backGroundView)
        
        backGroundView.backgroundColor = .lightBlue
        
        NSLayoutConstraint.activate([
            backGroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backGroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backGroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backGroundView.heightAnchor.constraint(equalToConstant: 350)
        ])
        
        backGroundView.addSubview(employeeNameLabel)
        
        backGroundView.addSubview(employeeNameTextField)
        
        backGroundView.addSubview(dateLabel)
        
        backGroundView.addSubview(datePicker)
        
        backGroundView.addSubview(segmentedControl)
        
        datePicker.datePickerMode = .date
        datePicker.tintColor = .darkGray
        
        NSLayoutConstraint.activate([
            
            employeeNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            employeeNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            employeeNameLabel.heightAnchor.constraint(equalToConstant: 50),
            employeeNameLabel.widthAnchor.constraint(equalToConstant: 100),
            
            employeeNameTextField.topAnchor.constraint(equalTo: employeeNameLabel.topAnchor),
            employeeNameTextField.leadingAnchor.constraint(equalTo: employeeNameLabel.trailingAnchor),
            employeeNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            employeeNameTextField.bottomAnchor.constraint(equalTo: employeeNameLabel.bottomAnchor),
            
            
            dateLabel.topAnchor.constraint(equalTo: employeeNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: employeeNameLabel.leadingAnchor),
            dateLabel.heightAnchor.constraint(equalTo: employeeNameLabel.heightAnchor),
            dateLabel.widthAnchor.constraint(equalTo: employeeNameLabel.widthAnchor),
            
            datePicker.topAnchor.constraint(equalTo: employeeNameLabel.bottomAnchor, constant: 5),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            
            segmentedControl.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
}

extension CreateEmployeeController {
    
    @objc func handleCreate() {
        
        let employee = CoreDataManager.shared.getObjectForContext(entityObject: Employee.self)
        
        guard let text = employeeNameTextField.text else { return }
        
        employee?.name = text
        
        let employeeInformation = CoreDataManager.shared.getObjectForContext(entityObject: EmployeeInformation.self)
        
        employeeInformation?.joinedDate = datePicker.date
        
        employee?.employeeInfo = employeeInformation
        
        employee?.company = company
        
        employee?.role = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        
        do {
            try CoreDataManager.shared.persistentContainer.viewContext.save()
            
            dismiss(animated: true, completion: { [unowned self] in
                self.didTapCreateButton?(employee)
            })
            
        } catch let error {
            print(error)
        }
    }
    
    @objc func handleClose() {
        dismiss(animated: true, completion: nil)
    }
}
