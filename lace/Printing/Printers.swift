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
    case DataError(String)
    
    static func wrap(_ e : OSStatus) throws {
        guard e==0 else { throw PrinterError.GeneralError(e) }
    }
}


class PrinterInfo : Sequence,CustomStringConvertible  {
    typealias Iterator=Array<PMResolution>.Iterator
    let name : String
    let id : String
    let model : String?
    let url : URL
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
        
        var u : Unmanaged<CFURL>?
        PMPrinterCopyDeviceURI(printer, &u)
        guard let url = u?.takeUnretainedValue() else { throw PrinterError.DataError("URL") }
        self.url=url as URL
        
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
    
    var printerState: String? {
        do {
            var state : PMPrinterState = 0
            try PrinterError.wrap(PMPrinterGetState(self.printer, &state))
            let pstate : Int=numericCast(state)
            switch pstate {
            case kPMPrinterIdle:
                return "Idle"
            case kPMPrinterProcessing:
                return "Processing"
            case kPMPrinterStopped:
                return "Stopped"
            default:
                return "Unknown"
            }
        }
        catch { return "Error" }
    }
    
    
    
    var isDefault : Bool { PMPrinterIsDefault(self.printer) }
    func mimeTypeIsSupported(_ mime: String) -> Bool { self.mimeTypes.contains(mime) }
    
    var description: String { "Name : \(name) ID: \(id) Model: \(model ?? "")" }
    
    var count : Int { resolutions.count }
    func makeIterator() -> Array<PMResolution>.Iterator { resolutions.makeIterator() }
    
    

    
}





class PrintSystem : Sequence {
    public typealias Iterator=Array<PrinterInfo>.Iterator
    
    public private(set) var printers : [PrinterInfo] = []
    
    public init() throws {
        var p : Unmanaged<CFArray>?
        try PrinterError.wrap(PMServerCreatePrinterList(nil, &p))
        if let ps = p?.takeUnretainedValue()
        {
            let range=0..<(CFArrayGetCount(ps))
            let printers : [PMPrinter] = range.compactMap { i in PMPrinter(CFArrayGetValueAtIndex(ps, i)) }
            self.printers = try printers.map { try PrinterInfo($0) }
        }
        else { self.printers = [] }
    }
    
    public var defaultPrinter : PrinterInfo? { printers.first { $0.isDefault }}
    
    public var count : Int { printers.count }
    func makeIterator() -> Iterator { printers.makeIterator() }
    
    subscript(_ id : String) -> PrinterInfo? { printers.first { $0.id == id } }
    var def : PrinterInfo? { printers.first { $0.isDefault } }
    
    func show() { printers.forEach { print($0.description) } }
}


