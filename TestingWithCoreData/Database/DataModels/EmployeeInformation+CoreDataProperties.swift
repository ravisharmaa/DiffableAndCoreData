//
//  EmployeeInformation+CoreDataProperties.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/19/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//
//

import Foundation
import CoreData


extension EmployeeInformation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EmployeeInformation> {
        return NSFetchRequest<EmployeeInformation>(entityName: "EmployeeInformation")
    }

    @NSManaged public var joinedDate: Date?
    @NSManaged public var taxId: String?
    @NSManaged public var employee: Employee?

}
