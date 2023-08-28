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
    
    convenience init(context moc: NSManagedObjectContext,bits: BitArray) {
        self.init(context: moc)
        self.grid=bits.binary
    }
    convenience init(context moc: NSManagedObjectContext,nBits: Int) {
        self.init(context: moc)
        self.grid=BitArray(nBits: nBits).binary
    }
    
    func getGrid(size: GridSize) -> Grid? {
        guard let d = self.grid else { return nil }
        return Grid(size: size, data: BitArray(binary: d, nBits: size.count))
    }
    
    func setGrid(_ grid: Grid) {
        self.grid=grid.data.binary
    }
    
    static func make(in moc: NSManagedObjectContext,nBits: Int) -> DataGrid {
        DataGrid.init(context: moc,nBits: nBits)
    }
    static func make(in moc: NSManagedObjectContext,bits: BitArray) -> DataGrid {
        DataGrid.init(context: moc,bits: bits)
    }
}
