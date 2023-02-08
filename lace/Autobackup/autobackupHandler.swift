//
//  autobackupHandler.swift
//  lace
//
//  Created by Julian Porter on 30/01/2023.
//

import Foundation
import CoreData

extension PrickingPoint : Comparable {
    public static func <(_ l : PrickingPoint,_ r : PrickingPoint) -> Bool {
        (l.y<r.y) || (l.y==r.y)&&(l.x<r.x)
    }
    
    var xi : Int { numericCast(x) }
    var yi : Int { numericCast(y) }
    
    public func flip() { self.state = !self.state }
    
    var grid : GridPoint { GridPoint(xi, yi) }
    func loadGrid(_ p : GridPoint) {
        self.x=p.x32
        self.y=p.y32
        self.state=false
    }
}

extension PrickingState {
    var w : Int { numericCast(width) }
    var h: Int { numericCast(height) }
    
    var size : GridSize {
        get { GridSize(w,h) }
        set(g) {
            width=g.width32
            height=g.height32
        }
    }
}

extension Data {
    
    init (boolean array : [Bool]) {
        let bytes : [UInt8] = array.map { $0 ? 1 : 0 }
        self.init(bytes)
    }
    
    var asBoolean : [Bool] {
        (0..<count).map { ($0 != 0) }
    }
}


class DataManager {

    
    
    var persistentContainer : NSPersistentContainer
    var moc : NSManagedObjectContext { self.persistentContainer.viewContext }
    
    init(model : String) {
        self.persistentContainer = NSPersistentContainer(name: model)
    }
    
    func connect() async throws -> NSManagedObjectContext {
        return try await withCheckedThrowingContinuation { continuation in
            self.persistentContainer.loadPersistentStores { description, error in
                if let error=error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(returning: self.persistentContainer.viewContext)
                }
            }
        }
    }
    
    func handler<T>() throws -> Handler<T> where T : NSManagedObject { try Handler<T>(self.moc) }
    
    class Handler<T> where T : NSManagedObject {
        enum Errors : Error {
            case BadTypeName
        }
        
        var moc : NSManagedObjectContext
        var name : String
        let entity : NSEntityDescription
        
        init(_ moc: NSManagedObjectContext) throws {
            self.moc=moc
            guard let name = T.entity().name else { throw Errors.BadTypeName }
            self.name=name
            self.entity=T.entity()
        }
        
        func commit() throws { try self.moc.save() }
        
        func getAll() throws -> [T] {
            let request = NSFetchRequest<T>(entityName: self.name)
            return try moc.performAndWait { try self.moc.fetch(request) }
        }
        func deleteAll() throws {
            let all = try getAll()
            all.forEach { self.moc.delete($0) }
        }
        func insert(_ object : T) { self.moc.insert(object) }
        func delete(_ object : T) { self.moc.delete(object) }
        func new() -> T { return T(entity: self.entity, insertInto: self.moc) }
        
        
        func getFirst() throws -> T? {
            let values : [T] = (try? getAll()) ?? []
            return values.first
        }
        func getFirstOrCreate() throws -> T {
            if let v : T = try getFirst() { return v }
            var w : T = new()
            return w
        }
    }
}

extension PrickingData {
    
    var w : Int {
        get { numericCast(width) }
        set { width=numericCast(newValue) }
    }
    var h : Int {
        get { numericCast(height) }
        set { height=numericCast(newValue) }
    }
    
    var grid : Grid {
        get { Grid(width: self.w, height: self.h, data: self.points ?? []) }
        set(g) {
            self.w=g.width
            self.h=g.height
            self.points=g.data
            self.timestamp=Date.timeIntervalSinceReferenceDate
        }
    }
    
    func empty() {
        self.width=0
        self.height=0
        self.points=[]
        self.timestamp=0
    }
    
}

class ManageGrid {

    
    enum Errors : Error {
        case NoConnection
    }
    let dm : DataManager
    var pricking : DataManager.Handler<PrickingData>
        
    init(model : String) async throws {
        let dm = DataManager(model: model)
        let moc = try await dm.connect()
        
        self.dm=dm
        self.pricking = try DataManager.Handler(moc)
    }
    
    func reset() {
        do {
            try pricking.deleteAll()
            try pricking.commit()
        }
        catch(let e) { syslog.error("\(e.localizedDescription)") }
    }
    
    func load() -> Grid? { try? self.pricking.getFirst()?.grid }

    func save(_ grid : Grid) {
        do {
            var v = try pricking.getFirstOrCreate()
            v.grid=grid
            try pricking.commit()
        }
        catch(let e) { syslog.error("\(e.localizedDescription)") }
    }
    
  
    

    
    
}




