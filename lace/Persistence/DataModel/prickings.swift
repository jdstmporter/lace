//
//  prickings.swift
//  lace
//
//  Created by Julian Porter on 27/07/2023.
//

import Foundation
import CoreData
import BitArray

extension PrickingData {
    
    convenience init(context moc: NSManagedObjectContext,name: String, kind: LaceKind, size: GridSize) {
        self.init(context: moc)
        self.name=name
        self.kind=kind.index
        self.uid=UUID()
        self.created=Date.now
        
        self.size=size
        
    }
    
  
    
    func getLayers() throws  -> [LayerData] {
        self.layers?.array.compactMap { $0 as? LayerData } ?? []
    }
    
    func insertLayer(_ ld : LayerData, at: Int) {}
    func insertLayer(_ ld : LayerData) {} // at end
    func removeLayer(at: Int) {}
    func removeLayers() {} // all
    
    
    
    var size: GridSize {
        get { GridSize(self.width,self.height) }
        set {
            self.width=newValue.width
            self.height=newValue.height
        }
    }
    
    func getPricking() -> Pricking {
        Pricking(name: self.name ?? "Pricking")
    }
    
    var laceKind : LaceKind {
        get { LaceKind(index: self.kind) }
        set { self.kind=newValue.index }
    }
    
    
    
    
}

