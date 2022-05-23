//
//  PrintingPanel.swift
//  lace
//
//  Created by Julian Porter on 22/05/2022.
//

import AppKit


class PrintingPanel : NSPanel, LaunchableItem {
    static var lock = NSLock()
    static var nibname : NSNib.Name = NSNib.Name("Printing")
    static var panel : PrintingPanel? = nil
    var firstTime : Bool = true
    var printSystem : PrintSystem?
    
    static let defaultResolutions : [Int] = [72,150,300,600,720,1200,2400]
    
    
    @IBOutlet weak var view : NSView!
    @IBOutlet weak var printers : NSPopUpButton!
    @IBOutlet weak var printerButton : NSButton!
    @IBOutlet weak var listButton: NSButton!
    @IBOutlet weak var resolutions: NSPopUpButton!
    
    
    
    @IBAction func resolutionsButton(_ sender: NSPopUpButton) {
    }
    
    
    @IBAction func choiceAction(_ button: NSButton!) {
        if printerButton.state == .on {
            printers.isEnabled = true
            printerAction(nil)
        }
        else {
            printers.isEnabled = false
            resolutions.removeAllItems()
            resolutions.addItems(withTitles: PrintingPanel.defaultResolutions.map { "\($0)" } )
            resolutions.selectItem(at: 0)
        }
    }
    
    @IBAction func printerAction(_ button: NSPopUpButton!) {
        guard let pr = printSystem?[printers.indexOfSelectedItem] else { return }
        let res = pr.resolutions.map { $0.width.description }
        resolutions.removeAllItems()
        resolutions.addItems(withTitles: res)
        resolutions.selectItem(at: 0)
    }
    
    static func launch() -> PrintingPanel? {
        if panel==nil {
            panel=instance()
            panel?.initialise()
            
        }
        panel?.makeKeyAndOrderFront(nil)
    
        return panel
    }
    
    @discardableResult static func close() -> PrintingPanel? {
        panel?.performClose(nil)
        return panel
    }
    
    func initialise() {
        if firstTime {
            printSystem = try? PrintSystem()
            printers.removeAllItems()
            printSystem?.forEach { printers.addItem(withTitle: $0.name) }
            let sel = printSystem?.defaultPrinterIndex ?? 0
            printers.selectItem(at: sel)
            
            choiceAction(nil)
            
            // do first time round things
            
            //NotificationCenter.default.addObserver(self, selector: #selector(colourChanged(_:)), name: //NSColorPanel.colorDidChangeNotification, object: nil)
            firstTime=false
        }

    }
}

