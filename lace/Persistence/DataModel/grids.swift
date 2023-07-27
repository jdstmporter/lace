//
//  grids.swift
//  lace
//
//  Created by Julian Porter on 28/07/2023.
//

import Foundation
import CoreData
import BitArray

extension DataGrid {
    
    func getGrid(size: GridSize) -> Grid? {
        guard let d = self.grid else { return nil }
        return Grid(size: size, data: BitArray(binary: d, nBits: size.count))
    }
    
    func setGrid(_ grid: Grid) {
        self.grid=grid.data.binary
    }
    
    static func make(in moc: NSManagedObjectContext,nBits: Int) -> DataGrid {
        var item=DataGrid.init(context: moc)
        item.grid=BitArray(nBits: nBits).binary
        return item
    }
    static func make(in moc: NSManagedObjectContext,bits: BitArray) -> DataGrid {
        var item=DataGrid.init(context: moc)
        item.grid=bits.binary
        return item
    }
}
