//
//  core.swift
//  lace
//
//  Created by Julian Porter on 04/10/2022.
//

import Foundation
import CoreData



class CoreDataManager {
    enum State {
        case Initialising
        case Active
        case Error
    }
    
    var persistentContainer: NSPersistentContainer
    var state : State = .Initialising
    
    
    init(model : String) throws {
        self.persistentContainer = NSPersistentContainer(name: model)
        self.persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                syslog.announce("Core data error: \(error)")
                self.state = .Error
            }
            self.state = .Active
            
        }
    }
    
    var context : NSManagedObjectContext {
        var ctx = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        ctx.persistentStoreCoordinator = self.persistentStoreCoordinator
        return ctx
    }
    
    func load<T>() -> [T] where T : NSManagedObject {
        
        let context=self.context
        
        var request = NSFetchRequest<T>()
        request.entity = T.entity()
        
        var out : [T] = []
        context.performAndWait {
            out = (try? context.fetch(request)) ?? []
        }
        return out
    }
    
    func save() {
        let context=self.context
        try? context.performAndWait {
            try context.save()
        }
    }
    
    
    
    var isValid : Bool { self.state == .Active }
    var managedObjectModel : NSManagedObjectModel { persistentContainer.managedObjectModel }
    var persistentStoreCoordinator : NSPersistentStoreCoordinator { persistentContainer.persistentStoreCoordinator }
}
