//
//  Colours.swift
//  lace
//
//  Created by Julian Porter on 18/04/2022.
//

import Foundation
import AppKit
import CoreGraphics



extension NSColor {
    
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

extension NSColor : HasDefault {
    public static var zero : NSColor { .black }
    public static func def(_ v : ViewPart) -> NSColor {
        (v == .Background) ? .white.deviceRGB : .black.deviceRGB
    }
}

extension NSFont : HasDefault {
    public static var zero : NSFont { NSFont.systemFont(ofSize: NSFont.systemFontSize) }
    public static func def(_ v : ViewPart) -> NSFont {
        var size = NSFont.systemFontSize
        switch v {
        case .Title:
            size+=2
        case .Metadata:
            break
        case .Comment:
            size=NSFont.smallSystemFontSize
        default:
            break
        }
        return NSFont.systemFont(ofSize: size)
    }
}

