//
//  InMemoryCoreDataStack.swift
//  starfallTests
//
//  Created by Eris He on 2/4/24.
//

import Foundation
import CoreData

class InMemoryCoreDataStack {
    static let shared = InMemoryCoreDataStack()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "starfall")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Use in-memory store
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
