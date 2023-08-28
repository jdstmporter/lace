//
//  prickings.swift
//  lace
//
//  Created by Julian Porter on 27/07/2023.
//

import Foundation
import CoreData
import BitArray

extension DataPricking {
    
    convenience init(context moc: NSManagedObjectContext,name: String, size: GridSize) {
        self.init(context: moc)
        self.name=name
        self.size=size
        self.uuid=UUID()
        self.created=Date.now
        
    }
    
    func layers() throws  -> [DataLayer] {
        guard let uuid=self.uuid else { throw DataError.PrickingHasNilIdentity }
        guard let moc=self.managedObjectContext else { throw DataError.PrickingHasNoManagedObjectContext }
        guard let name = DataLayer.entity().name else { throw DataError.BadTypeNameForDataLayer }
  
        let request = NSFetchRequest<DataLayer>(entityName: name)
        request.predicate=NSPredicate(format: "parent == %@", argumentArray: [uuid])
        return try moc.performAndWait { try moc.fetch(request) }
    }
    
    var size : GridSize {
        get { GridSize(self.width,self.height) }
        set(sz) {
            self.width=sz.width
            self.height=sz.height
        }
    }
    
    func getGrid() -> Grid {
        guard let g=self.gridData?.getGrid(size: self.size) else { return Grid(size: self.size) }
        return g
    }
    func setGrid(_ grid : Grid) throws {
        self.size=grid.size
        self.gridData?.setGrid(grid)
    }
    
    func getPricking() -> Pricking {
        let g=self.getGrid()
        let p=Pricking(name: self.name ?? "Pricking",)
    }
    
    var laceKind : LaceKind {
        get { LaceKind(index: self.kind) }
        set { self.kind=newValue.index }
    }
    
    
    static func make(in moc: NSManagedObjectContext,name: String="Default",size: GridSize = GridSize(1,1)) -> DataPricking {
        let pricking=DataPricking(context: moc,name: name,size: size)
        let grid=DataGrid.make(in: moc, nBits: size.count)
        pricking.gridData=grid
        grid.parent=pricking
        return pricking
    }
    
}

