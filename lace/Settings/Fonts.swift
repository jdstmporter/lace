//
//  Fonts.swift
//  lace
//
//  Created by Julian Porter on 01/05/2022.
//

import Foundation
import AppKit

// title, metadata comments

extension NSFont {
    
    var components : [String:Any] {
        var out : [String:Any] = [:]
        out["Name"]=self.fontName
        out["Size"] = self.pointSize
        return out
    }
    
    convenience init?(components c: [String:Any]) {
        guard let name = c["Name"] as? String else { return  nil }
        let size = c["Size"] as? CGFloat ?? 12.0
        self.init(name: name, size: size)
    }
}

class FontsController : NSViewController {
    
    var viewFonts : ViewFonts! { view as? ViewFonts }
    
    
}

enum FontPart : Int, CaseIterable {
    case Title = 0
    case Metadata = 1
    case Comment = 2
}

protocol ViewPartProtocol : Sequence where Iterator == Dictionary<Key, Value>.Iterator {
    associatedtype Value
    associatedtype Key : Hashable
    
    static var PREFIX : String { get }
    var values : [Key:Value] { get set }
    
    init()
    
    func defaultValue(_ : Key) -> Value
    subscript(_ : Key) -> Value { get set }
    func has(_ : Key) -> Bool
    
    func touch()
    func reset()
    
    func saveDefault() throws
    func loadDefault()
}



class ViewPartFonts {
    
    
    static let PREFIX = "Fonts-"
    
    typealias Container=[FontPart:NSFont]
    typealias Iterator=Container.Iterator
    internal var values : Container = [:]
    
    public static func defaults() -> ViewPartFonts {
        let c=ViewPartFonts()
        c.loadDefault()
        return c
    }
    
    init() {  }
    
    internal func defaultValue(_ p : FontPart) -> NSFont {
        var size = NSFont.systemFontSize
        switch p {
        case .Title:
            size+=2
        case .Metadata:
            break
        case .Comment:
            size=NSFont.smallSystemFontSize
        }
        return NSFont.systemFont(ofSize: size)
    }
    
    public subscript(_ p : FontPart) -> NSFont {
        get { values[p] ?? defaultValue(p) }
        set { values[p] = newValue }
    }
    public func has(_ p : FontPart) -> Bool { values[p] != nil }
    public func makeIterator() -> Iterator { values.makeIterator() }
    
    public func touch() {}
    public func reset() { self.values.removeAll() }
    
    public func saveDefault() throws {
        try FontPart.allCases.forEach { p in
            try Defaults.setFont(value: self[p], forKey: "\(ViewPartFonts.PREFIX)\(p)")
        }
    }
    public func loadDefault() {
        self.values.removeAll()
        FontPart.allCases.forEach { p in
            do { self[p]=try Defaults.font(forKey: "\(ViewPartFonts.PREFIX)\(p)") }
            catch(let e) {
                print("Error loading: \(e) - reverting to default")
            }
        }
    }
}

class ViewFonts : NSView, SettingsFacet {
    

    
    enum Fonts : Int, CaseIterable {
        case Title = 0
        case Metadata = 1
        case Comment = 2
    }
    
    @IBOutlet weak var titleText : NSTextField!
    @IBOutlet weak var metadataText : NSTextField!
    @IBOutlet weak var commentText : NSTextField!
    
    @IBOutlet weak var titleButton : NSButton!
    @IBOutlet weak var metadataButton : NSButton!
    @IBOutlet weak var commentButton : NSButton!
    
    var labels : [FontPart:NSTextField] = [:]
    var fonts = ViewPartFonts()
    var part : FontPart?
    
    func initialise() {
        labels[.Title] = titleText
        labels[.Metadata] = metadataText
        labels[.Comment] = commentText
        
        self.load()
    }
    
    func load() {
        fonts.loadDefault()
        DispatchQueue.main.async {[self] in
            FontPart.allCases.forEach { font in
                if let label=labels[font] { label.font = fonts[font] }
            }
        }
    }
    
    func save() throws {
        FontPart.allCases.forEach { font in
            if let label=labels[font], let f = label.font { fonts[font] = f }
        }
        try self.fonts.saveDefault()
    }
    
    func callback(_ f : NSFont) {
        guard let p=self.part else { return }
        self.part=nil
        fonts[p]=f
        DispatchQueue.main.async { [self] in labels[p]?.font=f }
    }
    
    @IBAction func actionCallback(_ button: NSButton!) {
        guard let part=FontPart(rawValue: button.tag) else { return }
        self.part=part
        let font=fonts[part]
        let callback : FontChanger.Callback = { self.callback($0) }
        let fc=FontChanger(callback: callback)
        fc.change(font)
    }
    
}

class FontChanger {
    typealias Callback = (NSFont) -> ()
    
    var font : NSFont!
    var callback : Callback!
    
    init(callback : @escaping Callback) {
        self.callback=callback
        
        let fm = NSFontManager.shared
        fm.target=self
        fm.action=#selector(changeFont(_:))
    }
    
    @objc func changeFont(_ sender : Any?) {
        guard let fm = sender as? NSFontManager, let fo = self.font else { return }
        let f = fm.convert(fo)
        callback?(f)
    }
    
    func change(_ font : NSFont) {
        self.font=font
        
        let panel = NSFontPanel.shared
        panel.isEnabled=true
        panel.setPanelFont(self.font, isMultiple: false)
        panel.worksWhenModal=true
        
        panel.makeKeyAndOrderFront(self)
    }
}
