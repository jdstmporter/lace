//
//  DraingPanel.swift
//  lace
//
//  Created by Julian Porter on 24/04/2022.
//

import Foundation
import AppKit



class DrawingView : NSView, SettingsFacet, NSFontChanging {
    
    
    
    var wells : [ViewPart:NSColorWell] = [:]
    var fields : [ViewPart:NSTextField] = [:]
    var labels : [FontPart:NSTextField] = [:]
    

    
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
    
    
    @IBOutlet weak var pathView : NSPathControl!
    
    
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
    var part : FontPart?
    
    var paths = ViewPaths()
    

    func touch() {
        ViewPart.allCases.forEach { row in
            if let well = wells[row] { cols[row]=well.color }
            if let field = fields[row] { dims[row]=field.doubleValue }
        }
        
        laceView.touch()
        
    }
    
    func setLabel(_ p : FontPart) {
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
        FontPart.allCases.forEach { self.setLabel($0) }
        paths.revert()
        self.pathView.url=paths[.DataDirectory]
    }
    
    
    
    func load()  {
        self.laceView.reload()
        self.fonts.revert()
        DispatchQueue.main.async {[self] in
            ViewPart.allCases.forEach { row in
                if let well = wells[row] { well.color = cols[row] }
                if let text = fields[row] { text.doubleValue = dims[row] }
            }
            FontPart.allCases.forEach { self.setLabel($0) }
            self.pathView.url=paths[.DataDirectory]
        }
        self.part=nil
        
    }
    
    func save() throws {
        cols.commit()
        dims.commit()
        fonts.commit()
 
        paths.commit()
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
            laceView.pricking.flip(p)
        }
        laceView.pricking.append(GridLine(GridPoint(0,0), GridPoint(8,8)))
        laceView.pricking.append(GridLine(GridPoint(1,1), GridPoint(1,7)))
        
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
    
    @IBAction func sizesEvent(_ field : NSTextField) {
        self.touch()
    }
    
    func colour(_ row : ViewPart) -> NSColor? { self.cols[row] }
    
    func cleanup() {
        NSColorPanel.shared.close()
        NSFontPanel.shared.close()
        self.part=nil
    }
    
    @IBAction func pathChange(_ obj : Any) {
        let fp = FilePicker(url: self.paths[.DataDirectory], types: [])
        guard fp.runSync(), let dir=fp.dir else { return }
        self.paths[.DataDirectory]=dir.asDirectory()
        self.load()
    }
    
    @objc func fontPanelClosed(_ event : NSNotification) {
        self.part=nil
        NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: NSFontPanel.shared)
    }
    
    @IBAction func fontEvent(_ button: NSButton!) {
        guard let part=FontPart(rawValue: button.tag) else { return }
        self.part=part
        let font=fonts[part]
        syslog.debug("Changing part \(part) with current font \(font)")
        
        NSFontManager.shared.target=self
        NSFontPanel.shared.setPanelFont(font, isMultiple: false)
        NSFontPanel.shared.makeKeyAndOrderFront(self)
        NotificationCenter.default.addObserver(self, selector: #selector(fontPanelClosed), name: NSWindow.willCloseNotification, object: NSFontPanel.shared)
       
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
        //self.part=nil
    }

}

