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
        
        // avoids duplicate
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()
    
    let lazyContext: NSManagedObjectContext = {
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        return context
    }()
    
    //MARK:- Retrieves the data from entity object.
    
    func fetch <T: NSManagedObject>(entityObject: T.Type) -> [T]? {
        
        let request = NSFetchRequest<T>.init(entityName: String(describing: entityObject))
        
        do {
            let fetchedObject = try persistentContainer.viewContext.fetch(request)
            return fetchedObject
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
        
    }
    
    //MARK:- Retrieves the object to save.
    
    func getObjectForContext <T: NSManagedObject> (entityObject: T.Type) -> T? {
        
        //        let object = NSEntityDescription.insertNewObject(forEntityName: String(describing: entityObject), into: persistentContainer.viewContext) as? T
        
        let object = T(context: persistentContainer.viewContext) 
        
        return object
    }
    
    
    // MARK:- Deletes and object from storage.
    
    /// added  ```discardable``` to ignore the return value,  check if the deletion is successful or not.
    
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
    
    // MARK:- Deletes all records
    
    @discardableResult
    
    func batchDelete <T: NSManagedObject>(object: T.Type) -> Bool {
        
        let batchRequest = NSBatchDeleteRequest(fetchRequest: T.fetchRequest())
        
        do {
            try persistentContainer.viewContext.execute(batchRequest)
            return true
        } catch let error {
            print(error.localizedDescription)
        }
        
        return false
        
    }
    
    //MARK:- Gets the fetch request object for an entity.
    
    func getRequestObject <T: NSManagedObject>(object: T.Type) -> NSFetchRequest<T> {
        
        return NSFetchRequest<T>(entityName: String(describing: object))
    }
    
    
    // MARK:- Gets the private context for object.
    
    func privateContext() -> NSManagedObjectContext {
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        return context
    }
}
