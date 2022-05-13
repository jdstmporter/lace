import Foundation
import AppKit
import UniformTypeIdentifiers

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

var printers = PMPrinter.findPrinters()
printers.forEach { prt in
    print(prt.id ?? "-")
    print("num resolutions = \(prt.nResolutions) ")
    let chunks = prt.resolutions.map { "\($0.hRes) x \($0.vRes)" }
    print(chunks.joined(separator: " : "))
}

printers.forEach { prt in
    var m : Unmanaged<CFArray>?
    PMPrinterGetMimeTypes(prt, nil, &m)
    if let mm = m?.takeUnretainedValue() {
        let mmm = mm as! Array<CFString>
        let mmmm = mmm.map { $0 as! String }
        mmmm.forEach { print($0) }
    }
    
}

    
    
    


