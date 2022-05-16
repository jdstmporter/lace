import Foundation
import AppKit
import UniformTypeIdentifiers

enum PrinterError : Error {
    case GeneralError(OSStatus)
    case PointerError
    case PrinterNameError
    case PrinterIDError
    
    static func wrap(_ e : OSStatus) throws {
        guard e==0 else { throw PrinterError.GeneralError(e) }
    }
}


class PrinterInfo : Sequence,CustomStringConvertible  {
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
    
    var description: String { "Name : \(name) ID: \(id) Model: \(model ?? "")" }
    
    var count : Int { resolutions.count }
    func makeIterator() -> Array<PMResolution>.Iterator { resolutions.makeIterator() }
    
    
    var isDefault : Bool { PMPrinterIsDefault(self.printer) }
    func mimeTypeIsSupported(_ mime: String) -> Bool { self.mimeTypes.contains(mime) }
    
    private var session: PMPrintSession?
    private var settings : PMPrintSettings?
    
    private func prepare() throws {
        try PrinterError.wrap(PMCreateSession(&session))
        try PrinterError.wrap(PMSessionSetCurrentPMPrinter(session!, self.printer))
        
        try PrinterError.wrap(PMCreatePrintSettings(&settings))
        try PrinterError.wrap(PMSessionDefaultPrintSettings(session!, settings!))
    }
    
    private func setResolution(_ resolution : PMResolution) throws {
        var res=resolution
        try PrinterError.wrap(PMPrinterSetOutputResolution(self.printer, settings!, &res))
    }
    
    private func release() {
        PMRelease(&settings)
        settings=nil
        PMRelease(&session)
        session=nil
    }
    
    func print(data: Data, resolution: PMResolution,mime: String = "image/png") throws {
        guard let prov = CGDataProvider(data: data as CFData) else { return }
        
        try self.prepare()
        try self.setResolution(resolution)
        try PrinterError.wrap(PMPrinterPrintWithProvider(self.printer, settings!, nil, mime as CFString, prov))
        self.release()
        
    }
    func print(file: URL, resolution: PMResolution,mime: String = "image/png") throws {
        
         var session: PMPrintSession?
         var settings : PMPrintSettings?
        
        try PrinterError.wrap(PMCreateSession(&session))
        try PrinterError.wrap(PMSessionSetCurrentPMPrinter(session!, self.printer))
        
        try PrinterError.wrap(PMCreatePrintSettings(&settings))
        try PrinterError.wrap(PMSessionDefaultPrintSettings(session!, settings!))
        
        //try self.prepare()
        var res=resolution
        try PrinterError.wrap(PMPrinterSetOutputResolution(self.printer, settings!, &res))
        try PrinterError.wrap(PMPrinterPrintWithFile(self.printer, settings!, nil, mime as CFString, file as CFURL))
        //self.release()
    }
    
    
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



do {
    let pr=try PrintSystem()
    pr.show()
    let p = pr.defaultPrinter!
    p.resolutions.forEach { print($0) }
    let res=p.resolutions[0]
    let u=URL(fileURLWithPath: "/Users/julianporter/Pictures/Excel/78691.jpg")
    try p.print(file: u, resolution: res, mime: "image/jpg")
}
catch(let e) { print(e) }
    
    
    


