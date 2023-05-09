//
//  modelBase.swift
//  lace
//
//  Created by Julian Porter on 08/05/2023.
//

import Foundation
import CoreData

protocol IDataType {
    
    var created : Date? { get set }
    var uid : UUID? { get set }
    
    mutating func initialise()
    var isInitialised : Bool { get }
    
    var safeUID : UUID { get }
    var safeCreated : Date { get }
    
}

extension IDataType {
    
    public mutating func initialise() {
        self.created = Date.now
        self.uid = UUID()
    }
    public var isInitialised : Bool { (self.uid != nil) && (self.created != nil) }
    public var safeUID : UUID { self.uid ?? UUID.Null }
    public var safeCreated : Date { self.created ?? Date.distantPast }
}

extension Base : IDataType {
}
