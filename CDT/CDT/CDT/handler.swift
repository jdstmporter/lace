//
//  handler.swift
//  CDT
//
//  Created by Julian Porter on 04/02/2024.
//

import Foundation
import CoreData

enum DataError : Error {
    case BadTypeNameForDataLayer
}

class DataHandler {
    
    var container : NSPersistentContainer
    var moc : NSManagedObjectContext { self.container.viewContext }
    
    init(container : NSPersistentContainer) {
        self.container=container
    }
    func commit() {
        do { try self.moc.save() }
        catch(let e) { print("Error \(e.localizedDescription)") }
    }
    func getAll<T>() throws -> [T] where T : NSManagedObject {
            guard let name = T.entity().name else { throw DataError.BadTypeNameForDataLayer }
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
    func getOrCreate<T>() throws -> T where T : NSManagedObject {
        if let result : T = (try self.getAll().first) {
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



/*
 class Persist {
 typealias Callback = (DataHandler?) -> ()
 static let modelName = "LaceAppModel"
 
 static var handler : DataHandler? = nil
 static var callback : Callback? = nil
 
 static func load(_ name : String) {
 Task {
 let bootstrap = CoreDataBootStrap(model: self.modelName)
 self.handler = await bootstrap.connect()
 if let cb = self.callback { cb(self.handler) }
 }
 }
 }
 */

