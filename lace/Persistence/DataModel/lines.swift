//
//  lines.swift
//  lace
//
//  Created by Julian Porter on 27/07/2023.
//

import Foundation
import CoreData

extension DataLine {
    
    var start : GridPoint {
        get { GridPoint(self.startX, self.startY) }
        set {
            self.startX = newValue.x
            self.startY = newValue.y
        }
    }
    var end : GridPoint {
        get { GridPoint(self.endX, self.endY) }
        set {
            self.endX = newValue.x
            self.endY = newValue.y
        }
    }
    var line : GridLine {
        get { return GridLine(self.start,self.end) }
        set {
            self.start = newValue.start
            self.end = newValue.end
        }
    }
    
    static func make(in moc: NSManagedObjectContext,from l : GridLine) -> DataLine {
        var item=DataLine.init(context: moc)
        item.line=l
        return item
    }
    
}


extension DataLines {
    
    private func remove(_ item: DataLine) {
        self.removeFromLines(item)
        item.parent=nil
        self.managedObjectContext?.delete(item)
    }
    
    var all : [DataLine] {
        get { self.lines?.array.compactMap { $0 as? DataLine } ?? [] }
        set(nv) {
            self.removeAll()
            nv.forEach { self.append(item: $0) }
        }
    }
    var count : Int { self.lines?.count ?? 0 }
    
    func append(item: DataLine) { self.addToLines(item) }
    
    func removeAll() {
        var itms = self.all.map { $0 }
        itms.forEach { self.remove($0) }
    }
    func removeAt(at: Int) {
        var item = self.all[at]
        self.remove(item)
    }
    
    subscript(_ idx : Int) -> DataLine? {
        get { self.lines?.array[idx] as? DataLine }
        set {
            guard let nv=newValue else { return }
            self.insertIntoLines(nv, at: idx)
        }
    }
    
    static func make(in moc: NSManagedObjectContext,name: String="Default",parent: DataPricking,index: Int32 = -1) -> DataLines {
        super.make(in: moc, kind: LayerKind.Lines, parent: parent,index: index)
    }
    
}
