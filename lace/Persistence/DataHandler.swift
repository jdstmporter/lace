//
//  DataHandler.swift
//  lace
//
//  Created by Julian Porter on 17/04/2023.
//

import Foundation
import CoreData

struct BadTypeNameError : Error, Equatable {}

class DataHandler {
    
    var container : NSPersistentContainer
    var moc : NSManagedObjectContext { self.container.viewContext }
    
    init(container : NSPersistentContainer) {
        self.container=container
    }
    func commit() throws { try self.moc.save() }
    
    func getAll<T>() throws -> [T] where T : NSManagedObject {
        guard let name = T.entity().name else { throw BadTypeNameError() }
        let request = NSFetchRequest<T>(entityName: name)
        return try moc.performAndWait { try self.moc.fetch(request) }
    }
    func deleteAll<T>(typename: T.Type) throws where T : NSManagedObject {
        let all = try getAll()
        all.forEach { self.moc.delete($0) }
    }
    func insert<T>(_ object : T) where T : NSManagedObject { self.moc.insert(object) }
    func delete<T>(_ object : T) where T : NSManagedObject { self.moc.delete(object) }
    func new<T>() -> T where T : NSManagedObject { return T(entity: T.entity(), insertInto: self.moc) }
}

