//
//  DraingPanel.swift
//  lace
//
//  Created by Julian Porter on 24/04/2022.
//

import Foundation
import AppKit

class DrawingView : NSView, SettingsFacet, NSFontChanging {
    static let AllParts : [ViewPart] = [.Title,.Metadata,.Comment]
    
    var wells : [ViewPart:NSColorWell] = [:]
    var fields : [ViewPart:NSTextField] = [:]
    var labels : [ViewPart:NSTextField] = [:]
    //private var cols = ViewColours(.Temp)
    //private var dims = ViewDimensions(.Temp)
    
    @IBOutlet weak var backgroundColour: NSColorWell!
    @IBOutlet weak var gridColour: NSColorWell!
    @IBOutlet weak var pinColour: NSColorWell!
    @IBOutlet weak var lineColour: NSColorWell!
    @IBOutlet weak var gridSize: NSTextField!
    @IBOutlet weak var pinSize: NSTextField!
    @IBOutlet weak var lineSize: NSTextField!
    @IBOutlet weak var titleText : NSTextField!
    @IBOutlet weak var metadataText : NSTextField!
    @IBOutlet weak var commentText : NSTextField!
    
    @IBOutlet weak var titleButton : NSButton!
    @IBOutlet weak var metadataButton : NSButton!
    @IBOutlet weak var commentButton : NSButton!
    
    @IBOutlet weak var laceView : LaceView!
    
    
    var dims : ViewDimensions! {
        get { laceView?.dims }
        set { laceView?.dims = newValue }
    }
    var cols : ViewColours! {
        get { laceView?.colours }
        set { laceView?.colours = newValue }
    }
    var fonts : ViewFonts = ViewFonts()
    var part : ViewPart?
    
    func touch() {
        ViewPart.allCases.forEach { row in
            if let well = wells[row] { cols[row]=well.color }
            if let field = fields[row] { dims[row]=field.doubleValue }
        }
        
        laceView.touch()
        
    }
    func setLabel(_ p : ViewPart) {
        labels[p]?.stringValue = fonts[p].humanName
    }
    
    func revert() {
        cols.revert()
        laceView?.dims.revert()
        ViewPart.allCases.forEach { row in
            wells[row]?.color = cols[row]
            fields[row]?.doubleValue = dims[row]
        }
        laceView.touch()
        fonts.revert()
        Self.AllParts.forEach { self.setLabel($0) }
        
    }
    
    
    
    func load()  {
        self.laceView.reload()
        self.fonts.revert()
        DispatchQueue.main.async {[self] in
            ViewPart.allCases.forEach { row in
                if let well = wells[row] { well.color = cols[row] }
                if let text = fields[row] { text.doubleValue = dims[row] }
            }
            Self.AllParts.forEach { self.setLabel($0) }
        }
        
    }
    
    func save() throws {
        cols.commit()
        dims.commit()
        fonts.commit()
        self.touch()
    }
    
    func initialise() {
        wells[.Background] = backgroundColour
        wells[.Grid] = gridColour
        wells[.Pin] = pinColour
        wells[.Line] = lineColour
        
        fields[.Grid] = gridSize
        fields[.Pin] = pinSize
        fields[.Line] = lineSize
        
        labels[.Title] = titleText
        labels[.Metadata] = metadataText
        labels[.Comment] = commentText
        
        self.load()
        
        
        // set up dummy pricking
        //laceView.MaxWidth = 10.0
        //laceView.MaxHeight = 10.0
        laceView.spacingInMetres = 0.005 // 5 mm
        laceView.pricking=Pricking(10,10)
        (0..<5).forEach { n in
            let p = GridPoint(2*n, 2*n)
            laceView.pricking.grid.flip(p)
        }
        laceView.pricking.lines.append(GridLine(GridPoint(0,0), GridPoint(8,8)))
        laceView.pricking.lines.append(GridLine(GridPoint(1,1), GridPoint(1,7)))
        
        DispatchQueue.main.async { [self] in
            //laceView.setDelegates(cols,dims)
            laceView.touch()
        }
    }
    
    func colourEvent(_ well : NSColorWell) {
        if let matched = ViewPart.init(rawValue: well.tag) {
            syslog.debug("Changed in row \(matched)")
        }
        else { syslog.debug("Matched somewhere funny") }
        self.touch()
        ViewPart.allCases.forEach { syslog.debug("\($0) : \(self.cols[$0])") }
    }
    
    func sizesEvent(_ field : NSTextField) {
        self.touch()
    }
    
    func colour(_ row : ViewPart) -> NSColor? { self.cols[row] }
    
    func cleanup() {
        NSColorPanel.shared.close()
        NSFontPanel.shared.close()
    }
    
    @IBAction func fontEvent(_ button: NSButton!) {
        guard let part=ViewPart(rawValue: button.tag) else { return }
        self.part=part
        let font=fonts[part]
        syslog.debug("Changing part \(part) with current font \(font)")
        
        NSFontManager.shared.target=self
        NSFontPanel.shared.setPanelFont(font, isMultiple: false)
        NSFontPanel.shared.makeKeyAndOrderFront(self)
       
    }
    
    
    
    /// Callback from NSFontManager
    ///
    @objc func changeFont(_ sender : NSFontManager?) {
        guard let p=self.part else { return }
        
        syslog.debug("Got return: parameter is \(String(describing: sender))")
        guard let fm = sender else { return }
        let font = fm.convert(self.fonts[p])
        
        syslog.debug("Converted font")
        
        fonts[p]=font
        self.setLabel(p)
        self.part=nil
    }

}

