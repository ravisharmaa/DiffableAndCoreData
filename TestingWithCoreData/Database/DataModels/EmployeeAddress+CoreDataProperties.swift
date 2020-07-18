//
//  EmployeeAddress+CoreDataProperties.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/19/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//
//

import Foundation
import CoreData


extension EmployeeAddress {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeeAddress> {
        return NSFetchRequest<EmployeeAddress>(entityName: "EmployeeAddress")
    }

    @NSManaged public var city: String?
    @NSManaged public var state: String?
    @NSManaged public var zip: String?
    @NSManaged public var employee: Employee?

}
