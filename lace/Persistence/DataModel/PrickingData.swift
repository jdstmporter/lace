//
//  PrickingData.swift
//  lace
//
//  Created by Julian Porter on 08/05/2023.
//

import Foundation
import CoreData
import BitArray

struct TimeStamp : CustomStringConvertible {
    static let format : Date.ISO8601FormatStyle = .iso8601.year().month().day()
        .time(includingFractionalSeconds: true)
        .dateSeparator(.omitted).dateTimeSeparator(.space).timeSeparator(.omitted)
    
    let date : Date
    init(_ date : Date = Date.now) { self.date = date }
    var description: String { date.formatted(TimeStamp.format) }
}




extension PrickingData {
    
    var w : Int {
        get { numericCast(self.width) }
        set(i) { self.width=numericCast(i) }
    }
    var h : Int {
        get { numericCast(self.height) }
        set(i) { self.height=numericCast(i) }
    }
    var size : Int { w*h }
    
    var grid : BitArray {
        get { BitArray(binary: self.gridBytes ?? Data(),nBits: self.size) }
        set(a) { self.gridBytes=a.binary }
    }
    
    func update(pricking: PrickingSpecification) {
        self.w = pricking.width
        self.h = pricking.height
        self.kind = numericCast(pricking.kind.index)
        self.created = pricking.created
        self.uid = pricking.uid
        self.grid = pricking.grid
        self.name = pricking.name
    }
    
    convenience init(handler : DataHandler,pricking: PrickingSpecification = PrickingSpecification()) {
        self.init(context: handler.moc)
        self.update(pricking: pricking)
    }
    
    static func find(handler : DataHandler,uid : UUID) throws -> PrickingData? {
        try handler.getAll().first { $0.uid == uid }
    }

}

extension GridData {
    
    var data : BitArray {
        get { BitArray(binary: self.points ?? Data(), nBits: numericCast(self.nBits)) }
        set(b) {
            self.points =  b.binary
            self.nBits = numericCast(b.nBits)
        }
        
    }
}

