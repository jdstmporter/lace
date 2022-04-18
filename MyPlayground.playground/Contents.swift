import Cocoa

let c = NSColorSpace.availableColorSpaces(with: .rgb)
let n = c.map { "\($0)" }
//n.forEach { print($0) }

let d = NSColor.gray
print("\(d.colorSpace)")
let e = d.usingColorSpace(.sRGB)
print("\(e)")


extension NSColor {
    
    var rgba : [CGFloat] {
        guard let c = self.usingColorSpace(.sRGB) else { return [] }
        let n=c.numberOfComponents
        var a=Array<CGFloat>.init(repeating: 0, count: n)
        a.withUnsafeMutableBufferPointer { p in
            if let b = p.baseAddress {
                c.getComponents(b)
            }
        }
        return a
        
    }
    
  
    
    convenience init(_ c: [CGFloat]) {
        self.init(colorSpace: .sRGB,components: c,count: c.count )
    }
}

let f = d.rgba

let col = NSColor.white
let cl = col.usingColorSpace(.genericRGB)

