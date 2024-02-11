//
//  layers.swift
//  lace
//
//  Created by Julian Porter on 27/07/2023.
//

import Foundation
import CoreData



protocol LayerContent {
    var binary : Data { get }
    init?(binary : Data)
}


extension LayerData {
    
    convenience init(context moc: NSManagedObjectContext,name: String,kind : LayerKind, parent: PrickingData, data: (any LayerContent)? = nil, region: GridRect = GridRect()) {
        self.init(context: moc)
        self.name=name
        self.layerKind=kind
        self.parent=parent
        self.region=region
        self.data=data?.binary
    }
    
    func attach(to pricking: PrickingData) { self.parent=pricking }
    func detach() { self.parent=nil }
    
    var layerKind : LayerKind {
        get { LayerKind(self.kind) }
        set { self.kind=newValue.rawValue }
    }
    
    var origin: GridPoint {
        get { GridPoint(self.offsetY,self.offsetY) }
        set {
            self.offsetX=newValue.x
            self.offsetY=newValue.y
        }
    }
    var size: GridSize {
        get { GridSize(self.width,self.height) }
        set {
            self.width=newValue.width
            self.height=newValue.height
        }
    }
    
    var region : GridRect {
        get { GridRect(self.origin,self.size) }
        set {
            self.origin=newValue.origin
            self.size=newValue.size
        }
        
    }
    
    func payload<T>() -> T? where T : LayerContent {
        guard let d=self.data else { return nil }
        return T(binary: d)
    }
    func payload(_ c : any LayerContent) {
        self.data=c.binary
    }
    
    
    
}
