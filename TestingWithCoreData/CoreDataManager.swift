//
//  CoreDataManager.swift
//  TestingWithCoreData
//
//  Created by Ravi Bastola on 7/16/20.
//  Copyright © 2020 Ravi Bastola. All rights reserved.
//

import CoreData


struct CoreDataManager {
    
    private init () {}
    
    static let shared = CoreDataManager.init()
    
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                print(error.localizedDescription)
                assert(false)
            }
        }
        return container
    }()
    
    //MARK:- Retrieves the data from entity object
    
    func fetch <T: NSManagedObject>(entityObject: T.Type, entityName: String) -> [T]? {
        
        let request = NSFetchRequest<T>.init(entityName: entityName)
        
        do {
            let fetchedObject = try persistentContainer.viewContext.fetch(request)
            return fetchedObject
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
        
    }
    
    //MARK:- Retrieves the object to save.
    
    func getObjectForContext <T: NSManagedObject> (entityObject: T.Type, entityName: String) -> T? {
        
        let object = NSEntityDescription.insertNewObject(forEntityName: entityName, into: persistentContainer.viewContext) as? T
        
        return object
    }
    
    
    @discardableResult
    
    func deleteObject <T: NSManagedObject>(object: T) -> Bool {
        
        persistentContainer.viewContext.delete(object)
        
        do {
            try persistentContainer.viewContext.save()
            return true
        } catch let error {
            print(error)
        }
        
        return false
        
    }
}