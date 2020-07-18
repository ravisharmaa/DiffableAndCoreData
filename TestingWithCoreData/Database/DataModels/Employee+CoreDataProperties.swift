//
//  Employee+CoreDataProperties.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/19/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var name: String?
    @NSManaged public var role: String?
    @NSManaged public var company: CompanyEntity?
    @NSManaged public var employeeAddress: EmployeeAddress?
    @NSManaged public var employeeInfo: EmployeeInformation?

}
