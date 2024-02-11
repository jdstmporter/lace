//
//  grids.swift
//  lace
//
//  Created by Julian Porter on 28/07/2023.
//

import Foundation
import CoreData
import BitArray

extension GridData {
    
    private func load(grid: Grid) {
        self.width = grid.width
        self.height = grid.height
        self.data = grid.data.binary
    }
 
    convenience init(context moc: NSManagedObjectContext,grid: Grid) {
        self.init(context: moc)
        self.load(grid: grid)
    }
    convenience init(context moc: NSManagedObjectContext,size: GridSize) {
        self.init(context: moc)
        self.load(grid: Grid(size: size))
    }
    
    var size : GridSize {
        get { GridSize(self.width,self.height) }
        set {
            self.width=newValue.width
            self.height=newValue.height
        }
    }
    
    var grid : Grid {
        get {
            guard let d = self.data else { return Grid(size: self.size) }
            return Grid(size: self.size, data: BitArray(binary: d))
        }
        set {
            self.size=newValue.size
            self.data = newValue.data.binary
        }
    }
    
}
