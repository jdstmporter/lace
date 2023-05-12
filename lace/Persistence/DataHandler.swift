//
//  DataHandler.swift
//  lace
//
//  Created by Julian Porter on 17/04/2023.
//

import Foundation
import CoreData

enum DataError : BaseError {
    case BadType
}

class DataHandler {
    
    var container : NSPersistentContainer
    var moc : NSManagedObjectContext { self.container.viewContext }
    
    init(container : NSPersistentContainer) {
        self.container=container
    }
    func commit() {
        do { try self.moc.save() }
        catch(let e) { syslog.error(e.localizedDescription) }
    }
    func getAll<T>() throws -> [T] where T : NSManagedObject {
            guard let name = T.entity().name else { throw DataError.BadType }
            let request = NSFetchRequest<T>(entityName: name)
            return try moc.performAndWait { try self.moc.fetch(request) }
    }
    func deleteAll<T>(typename: T.Type) where T : NSManagedObject {
        guard let all = try? getAll() else { return }
            all.forEach { self.moc.delete($0) }
    }
    func insert<T>(_ object : T) where T : NSManagedObject { self.moc.insert(object) }
    func delete<T>(_ object : T) where T : NSManagedObject { self.moc.delete(object) }
    func new<T>() -> T where T : NSManagedObject { return T(entity: T.entity(), insertInto: self.moc) }
    
    func getOrCreate<T>(predicate: (T) -> Bool) throws -> T where T : NSManagedObject {
        if let result : T = (try self.getAll().first { predicate($0) }) {
            return result
        }
        else {
            return self.new()
        }
        
    }
    func get<T>(predicate: (T) -> Bool) -> T? where T : NSManagedObject {
        guard let all : [T] = try? self.getAll() else { return nil }
        return all.first { predicate($0) }
    }
    func delete<T>(_ typename: T.Type,predicate: (T) -> Bool) where T : NSManagedObject {
        guard let all : [T] = try? self.getAll(),
              let item : T = (all.first { predicate($0) })  else { return }
        delete(item)
    }
    
    
}
