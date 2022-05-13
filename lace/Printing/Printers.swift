//
//  Printers.swift
//  lace
//
//  Created by Julian Porter on 13/05/2022.
//

import Foundation
import AppKit

enum PrinterError : Error {
    case GeneralError(OSStatus)
    case PointerError
    case PrinterNameError
    case PrinterIDError
    
    static func wrap(_ e : OSStatus) throws {
        guard e==0 else { throw PrinterError.GeneralError(e) }
    }
}

extension PMPrinter {
    var name : String? {
        let nu : Unmanaged<CFString>? = PMPrinterGetName(self)
        return nu?.takeUnretainedValue() as String?
        
    }
    var id : String? {
        let nu : Unmanaged<CFString>? = PMPrinterGetID(self)
        return nu?.takeUnretainedValue() as String?
    }
    
    static func findPrinters() -> [PMPrinter] {
        var p : Unmanaged<CFArray>?
        let err = PMServerCreatePrinterList(nil, &p)
        guard err==0, let ps = p?.takeUnretainedValue() else { return [] }
        
        let range=0..<(CFArrayGetCount(ps))
        return range.compactMap { i in PMPrinter(CFArrayGetValueAtIndex(ps, i)) }
    }
    
    var resolutions : [PMResolution] {
        var n : UInt32 = 0
        let err = PMPrinterGetPrinterResolutionCount(self,&n)
        guard err==0 else { return [] }
        let range = 1...n
        return range.compactMap { idx in
            var res = PMResolution()
            let e = PMPrinterGetIndexedPrinterResolution(self, idx, &res)
            guard e==0 else { return nil }
            return res
        }
    }
    
    var nResolutions : Int {
        var n : UInt32 = 0
        let err = PMPrinterGetPrinterResolutionCount(self,&n)
        guard err==0 else { return 0 }
        return numericCast(n)
    }
}

class PrinterInfo : Sequence  {
    typealias Iterator=Array<PMResolution>.Iterator
    let name : String
    let id : String
    let model : String?
    let mimeTypes : [String]
    let resolutions : [PMResolution]
    let printer : PMPrinter
    
    init(_ printer: PMPrinter) throws {
        self.printer=printer
        
        let n : Unmanaged<CFString>? = PMPrinterGetName(printer)
        guard let nn = n?.takeUnretainedValue() as String? else { throw PrinterError.PrinterNameError }
        self.name=nn
        
        let i : Unmanaged<CFString>? = PMPrinterGetID(printer)
        guard let ii = i?.takeUnretainedValue() as String? else { throw PrinterError.PrinterIDError }
        self.id=ii
        
        var m : Unmanaged<CFString>?
        try PrinterError.wrap(PMPrinterGetMakeAndModelName(printer, &m))
        model = m?.takeUnretainedValue() as String?
        
        var mi : Unmanaged<CFArray>?
        try PrinterError.wrap(PMPrinterGetMimeTypes(printer, nil, &mi))
        if let mRet = mi?.takeUnretainedValue() {
            let cfs = mRet as! Array<CFString>
            mimeTypes = cfs.map { $0 as String }
        }
        else { mimeTypes=[] }
        
        var nr : UInt32 = 0
        try PrinterError.wrap(PMPrinterGetPrinterResolutionCount(printer,&nr))
        let range = 1...nr
        self.resolutions = range.compactMap { idx in
            var res = PMResolution()
            let e = PMPrinterGetIndexedPrinterResolution(printer, idx, &res)
            guard e==0 else { return nil }
            return res
        }
    }
    
    var count : Int { resolutions.count }
    func makeIterator() -> Array<PMResolution>.Iterator { resolutions.makeIterator() }
    
    
    var isDefault : Bool { PMPrinterIsDefault(self.printer) }
    func mimeTypeIsSupported(_ mime: String) -> Bool { self.mimeTypes.contains(mime) }
    
    func print(_ data: Data, resolution: PMResolution,mime: String = "image/png") throws {
        guard let prov = CGDataProvider(data: data as CFData) else { return }
        
        var session : PMPrintSession?
        try PrinterError.wrap(PMCreateSession(&session))
        try PrinterError.wrap(PMSessionSetCurrentPMPrinter(session!, self.printer))
        
        var settings : PMPrintSettings?
        try PrinterError.wrap(PMCreatePrintSettings(&settings))
        try PrinterError.wrap(PMSessionDefaultPrintSettings(session!, settings!))
        var res=resolution
        try PrinterError.wrap(PMPrinterSetOutputResolution(self.printer, settings!, &res))
        
        try PrinterError.wrap(PMPrinterPrintWithProvider(self.printer, settings!, nil, mime as CFString, prov))
        
        PMRelease(&settings)
        PMRelease(&session)
    }
    
    static func findPrinters() throws -> [PrinterInfo] {
        var p : Unmanaged<CFArray>?
        try PrinterError.wrap(PMServerCreatePrinterList(nil, &p))
        guard let ps = p?.takeUnretainedValue() else { return [] }
        
        let range=0..<(CFArrayGetCount(ps))
        let printers : [PMPrinter] = range.compactMap { i in PMPrinter(CFArrayGetValueAtIndex(ps, i)) }
        return try printers.map { try PrinterInfo($0) }
    }
}


class PrintSystem : Sequence {
    public typealias Iterator=Array<PrinterInfo>.Iterator
    
    public private(set) var printers : [PrinterInfo] = []
    
    public init() throws {
        self.printers = try PrinterInfo.findPrinters()
    }
    
    public var count : Int { printers.count }
    func makeIterator() -> Iterator { printers.makeIterator() }
    
    subscript(_ id : String) -> PrinterInfo? { printers.first { $0.id == id } }
    var def : PrinterInfo? { printers.first { $0.isDefault } }
}
