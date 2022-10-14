//
//  Displays.swift
//  lace
//
//  Created by Julian Porter on 16/07/2022.
//

import CoreGraphics
import AppKit

extension NSScreen {
    var displayID : CGDirectDisplayID? {
        self.deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID
    }
}

extension NSSize {
    static func *(_ lhs : CGFloat,_ rhs: NSSize) -> NSSize {
        NSSize(width: lhs*rhs.width, height: lhs*rhs.height)
    }
    static func *(_ lhs : NSSize,_ rhs: NSSize) -> NSSize {
        NSSize(width: lhs.width*rhs.width, height: lhs.height*rhs.height)
    }
    static func /(_ lhs : NSSize,_ rhs: NSSize) -> NSSize {
        NSSize(width: lhs.width/rhs.width, height: lhs.height/rhs.height)
    }
    var mean : Double { (self.width + self.height)*0.5 }
    var max : Double { Swift.max(self.width,self.height) }
}

class Display : CustomStringConvertible {
    let id : CGDirectDisplayID
    let size : NSSize
    let rect : NSSize
    
    init(screen id: CGDirectDisplayID) {
        self.id=id
        self.size = 0.001*CGDisplayScreenSize(id)
        self.rect = CGDisplayBounds(id).size
    }
    
    convenience init() {
        self.init(screen: CGMainDisplayID())
    }
    
    convenience init?(screen : NSScreen) {
        guard let id=screen.displayID else { return nil }
        self.init(screen: id)
    }
    
    convenience init?(window : NSWindow?) {
        guard let id=window?.screen?.displayID else { return nil }
        self.init(screen: id)
    }
    
    var resolutionDPM : NSSize { self.rect/self.size }
    func convertToMetres(pixels: NSSize) -> NSSize { pixels/self.resolutionDPM }
    func convertToPixels(metres: NSSize) -> NSSize { metres*self.resolutionDPM }
    
    var resolution : Double { self.resolutionDPM.max }
    func convertToPixels(metres: CGFloat) -> CGFloat { metres*self.resolution }
    
    var dotsPerMetre : Double { self.resolutionDPM.mean }
    
    var description: String { "\(self.id) : rect = \(self.rect) size = \(self.size) dpm = \(self.resolutionDPM)"}
    
    static var all : [Display] {
        var ids = Array<CGDirectDisplayID>.init(repeating: 0, count: 25)
        var n : UInt32 = 0
        let err=CGGetOnlineDisplayList(25, &ids, &n)
        guard err == .success else { return [] }
        return ids.prefix(numericCast(n)).map { Display(screen: $0) }
    }
}
