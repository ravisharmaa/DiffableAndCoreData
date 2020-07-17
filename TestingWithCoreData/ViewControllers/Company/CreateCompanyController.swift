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
    
    fileprivate lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Found Date"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
        
    }()
    
    fileprivate lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "imagePlaceholder"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTapped)))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        return imageView
    }()
    
    var didTapCreateButton: ((_ entity: CompanyEntity?)-> ())?
    
    var didEndEditing: ((_ entity: CompanyEntity?) -> ())?
    
    var companyEntity: CompanyEntity? {
        didSet {
            self.companyTextField.text = self.companyEntity?.name
            self.datePicker.date = self.companyEntity?.foundedDate ?? Date()
            if let image = self.companyEntity?.image {
                self.imageView.image = UIImage(data: image)
            }
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
            backGroundView.heightAnchor.constraint(equalToConstant: 350)
        ])
        
        backGroundView.addSubview(companyNameLabel)
        
        backGroundView.addSubview(companyTextField)
        
        backGroundView.addSubview(dateLabel)
        
        backGroundView.addSubview(datePicker)
        
        backGroundView.addSubview(imageView)
        
        datePicker.datePickerMode = .date
        datePicker.tintColor = .darkGray
        
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            
            companyNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            companyNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            companyNameLabel.heightAnchor.constraint(equalToConstant: 50),
            companyNameLabel.widthAnchor.constraint(equalToConstant: 100),
            
            companyTextField.topAnchor.constraint(equalTo: companyNameLabel.topAnchor),
            companyTextField.leadingAnchor.constraint(equalTo: companyNameLabel.trailingAnchor),
            companyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            companyTextField.bottomAnchor.constraint(equalTo: companyNameLabel.bottomAnchor),
            
            
            dateLabel.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: companyNameLabel.leadingAnchor),
            dateLabel.heightAnchor.constraint(equalTo: companyNameLabel.heightAnchor),
            dateLabel.widthAnchor.constraint(equalTo: companyNameLabel.widthAnchor),
            
            datePicker.topAnchor.constraint(equalTo: companyNameLabel.bottomAnchor, constant: 5),
            datePicker.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor)
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
        company?.setValue(datePicker.date, forKey: "foundedDate")
        
        if let image = imageView.image {
            let image = image.jpegData(compressionQuality: 0.8)
            company?.image = image
        }
        
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
        companyEntity?.foundedDate = datePicker.date
        
        if let image = imageView.image {
            let image = image.jpegData(compressionQuality: 0.8)
            companyEntity?.image = image
        }
        
        
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
    
    @objc func handleImageTapped() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
        
    }
}

extension CreateCompanyController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.imageView.image = image
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = originalImage
        }
        
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height / 2
        
        dismiss(animated: true, completion: nil)
    }
}
