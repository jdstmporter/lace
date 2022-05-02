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

class ViewPartFonts : Sequence {
    static let PREFIX = "Fonts-"
    
    typealias Container=[FontPart:NSFont]
    typealias Iterator = Container.Iterator
    private var values : Container = [:]
    
    public init() {}
    
    public static func defaults() -> ViewPartFonts {
        let c=ViewPartFonts()
        c.loadDefault()
        return c
    }
    
    private func defaultValue(_ p : FontPart) -> NSFont {
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
    func makeIterator() -> Iterator { values.makeIterator() }
    
    public func touch() {
        
    }
    public func reset() {
        self.values.removeAll()
    }
    
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
    func load() {
        <#code#>
    }
    
    func save() throws {
        <#code#>
    }
    
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
    
    var labels : [NSTextField] = []
    var fonts : [NSFont] = []
    
    func initialise() {
        labels = [titleText, metadataText, commentText]
        fonts = labels.map { $0.font ?? NSFont.labelFont(ofSize: 12)}
    }
    
    
    @IBAction func actionCallback(_ button: NSButton!) {
        let tag=button.tag
        guard tag>=0, tag<fonts.count else { return }
        let font=fonts[tag]
        let callback : FontChanger.Callback = { [self] f in
            labels[tag].font=f
            fonts[tag]=f
        }
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
