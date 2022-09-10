import AppKit
import Foundation

protocol DefaultValue : CustomStringConvertible {
    associatedtype V
    static var zero : V { get }
    
    var kind : Any.Type { get }
    var kindname : String { get }
}

extension DefaultValue {
    var kind : Any.Type { type(of: self as Any) }
    var kindname : String { "\(self.kind)"}
}

extension  Double : DefaultValue {}
extension NSColor : DefaultValue {
    static var zero: NSColor { .black  }
    
    var sRGB : NSColor { self.usingColorSpace(.sRGB) ?? self }
    var genericRGB : NSColor { self.usingColorSpace(.genericRGB) ?? self }
    var deviceRGB : NSColor { self.usingColorSpace(.deviceRGB) ?? self }
    
    var rgba : [CGFloat]? {
        guard let c = self.usingColorSpace(.deviceRGB) else { return nil }
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
        self.init(colorSpace: .deviceRGB,components: c,count: c.count )
    }
}

func tellMe<P>(_ val: P) {
    let t=type(of: val as Any)
    if t==String.self { print ("String") }
    else { print("Other: \(t)") }
}

tellMe("fred")
tellMe(5.0)
