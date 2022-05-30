//
//  Printers.swift
//  lace
//
//  Created by Julian Porter on 13/05/2022.
//

import Foundation
import AppKit
import UniformTypeIdentifiers




class Printer : Sequence,CustomStringConvertible, Comparable  {
    static func == (lhs: Printer, rhs: Printer) -> Bool { lhs.id==rhs.id }
    static func < (lhs: Printer, rhs: Printer) -> Bool { lhs.id<rhs.id }
    
    typealias Iterator=Array<NSSize>.Iterator
    let name : String
    let id : String
    let model : String?
    let resolutions : [NSSize]
    let printer : PMPrinter
    
    init(_ printer: PMPrinter) throws {
        self.printer=printer
        
        let n : Unmanaged<CFString>? = PMPrinterGetName(printer)
        guard let nn = n?.takeUnretainedValue() as String? else { throw PrinterError.CannotGetName }
        self.name=nn
        
        let i : Unmanaged<CFString>? = PMPrinterGetID(printer)
        guard let ii = i?.takeUnretainedValue() as String? else { throw PrinterError.CannotGetID }
        self.id=ii
        
        var m : Unmanaged<CFString>?
        try PrinterError.wrap(PMPrinterGetMakeAndModelName(printer, &m))
        model = m?.takeUnretainedValue() as String?
        
        var nr : UInt32 = 0
        try PrinterError.wrap(PMPrinterGetPrinterResolutionCount(printer,&nr))
        let range = 1...nr
        self.resolutions = range.compactMap { idx in
            var res = PMResolution()
            let e = PMPrinterGetIndexedPrinterResolution(printer, idx, &res)
            guard e==0 else { return nil }
            return NSSize(res)
        }
    }
    
    var isDefault : Bool { PMPrinterIsDefault(self.printer) }
    var description: String { "Name : \(name) ID: \(id) Model: \(model ?? "")" }
    var count : Int { resolutions.count }
    func makeIterator() -> Array<NSSize>.Iterator { resolutions.makeIterator() }
    subscript(_ n : Int) -> NSSize { resolutions[n] }
}

class PrintSystem : Sequence {
    public typealias Iterator=Array<Printer>.Iterator
    public private(set) var printers : [Printer] = []
    
    public init() throws {
        var p : Unmanaged<CFArray>?
        try PrinterError.wrap(PMServerCreatePrinterList(nil, &p))
        if let ps = p?.takeUnretainedValue()
        {
            let range=0..<(CFArrayGetCount(ps))
            let printers : [PMPrinter] = range.compactMap { i in PMPrinter(CFArrayGetValueAtIndex(ps, i)) }
            self.printers = try printers.map { try Printer($0) }.sorted()
        }
        else { self.printers = [] }
    }
    
    public var defaultPrinter : Printer? { printers.first { $0.isDefault }}
    public var defaultPrinterIndex : Int? { printers.firstIndex { $0.isDefault }}
    
    public var count : Int { printers.count}
    func makeIterator() -> Iterator { printers.makeIterator() }
    subscript(_ id : String) -> Printer? { printers.first { $0.id == id } }
    subscript(_ idx : Int) -> Printer { printers[idx] }
}


