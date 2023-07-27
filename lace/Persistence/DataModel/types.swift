//
//  types.swift
//  lace
//
//  Created by Julian Porter on 26/07/2023.
//

import Foundation
import CoreData

protocol ChildObject : NSManagedObject {
    associatedtype Parent : NSManagedObject
    
    var parent : Parent? { get set }
}



protocol OrderedSetProtocol : NSManagedObject {
    associatedtype Item : ChildObject
    
    // adapters
    var raw : NSOrderedSet? { get } // = self.<name>s
    func rawAppend(_ : Item) // = self.addTo<name>s(_ : Item)
    func rawInsert(_ : Item, at: Int) // = self.insertInto<name>s(_ : Item, at: Int)
    func rawRemove(_ : Item) // = self.removeFrom<name>s()
    
    var all : [Item] { get }
    var count : Int { get }
    func append(item: Item)
    func removeAll()
    func removeAt(_ idx : Int)
    subscript(_ idx : Int) -> Item? { get set }
}

extension OrderedSetProtocol {
    
    var all : [Item] { self.raw?.array.compactMap { $0 as? Item } ?? [] }
    var count : Int { self.raw?.count ?? 0 }
    
    func append(item: Item) { self.rawAppend(item) }
    
    func removeAll() {
        var itms = self.all.map { $0 }
        for itm in itms {
            self.rawRemove(itm)
            itm.parent=nil
            self.managedObjectContext?.delete(itm)
        }
    }
    func removeAt(at: Int) {
        var item = self.all[at]
        self.rawRemove(item)
        item.parent=nil
        self.managedObjectContext?.delete(item)
    }
    
    subscript(_ idx : Int) -> Item? {
        get { self.raw?.array[idx] as? Item }
        set {
            guard let nv=newValue else { return }
            self.rawInsert(nv, at: idx)
        }
    }
}


