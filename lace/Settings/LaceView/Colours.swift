//
//  Colours.swift
//  lace
//
//  Created by Julian Porter on 18/04/2022.
//

import Foundation
import AppKit
import CoreGraphics



extension NSColor  {
    
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

extension NSFont {
    convenience init?(components c: [String:Any]) {
        guard let name : String = c["name"] as? String, let size : CGFloat = c["size"] as? CGFloat else { return nil }
        self.init(name: name, size: size)
    }
    var components : [String:Any]? {
        var out : [String:Any] = [:]
        let attributes = self.fontDescriptor.fontAttributes
        guard let name = attributes[.name], let size = attributes[.size] else { return nil }
        out["name"] = name
        out["size"] = size
        return out
    }
    var humanName : String {
        let name=self.displayName ?? self.familyName ?? self.fontName
        return "\(name) \(self.pointSize)"
    }
}

extension URL {
    init?(resource r: String, extension ext: String) {
        guard let url = Bundle.main.url(forResource: r, withExtension: ext) else { return nil }
        self=url
    }
    init( _ s : String) { self.init(fileURLWithPath: s) }
    func asDirectory() -> URL { URL(fileURLWithPath: self.path, isDirectory: true) }
    static var userHome : URL { URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true) }
}

extension FileManager {
    func fileExists(at: URL) -> Bool { fileExists(atPath: at.path) }
}

struct FileInfo {
    let exists : Bool
    let dir: Bool
    
    init(at: URL) {
        var d = ObjCBool(false)
        self.exists = FileManager.default.fileExists(atPath: at.path, isDirectory: &d)
        self.dir=d.boolValue
    }
    init(exists: Bool,dir: Bool) {
        self.exists=exists
        self.dir=dir
    }
    var existsAsDir : Bool { exists && dir }
    var existsAsNonDir : Bool { exists && !dir }
}




