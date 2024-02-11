//
//  basicEntity.swift
//  CDT
//
//  Created by Julian Porter on 04/02/2024.
//

import Foundation
import CoreData

extension NSOrderedSet {
    
    func typedArray<T>() -> [T] { (self.array as? [T]) ?? [] }
}

extension Pricking {
    
    func getLayers() -> [Layer] {
        return self.layers?.typedArray() ?? []
    }
    
    func setLayers(_ layers: [Layer]) {
        guard let moc = self.managedObjectContext else { return }
        let len = self.layers?.count ?? 0
        
        (0..<len).reversed().forEach { self.removeFromLayers(at: $0) }
        self.getLayers().forEach { i in
            self.removeFromLayers(i)
            i.parent=nil
        }
        layers.forEach { l in
            self.addToLayers(l)
        }
    }
}


