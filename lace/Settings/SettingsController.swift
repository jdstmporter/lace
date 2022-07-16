//
//  SettingsController.swift
//  lace
//
//  Created by Julian Porter on 16/04/2022.
//

import Foundation
import AppKit

enum ViewPart : Int, CaseIterable {
    case Background = 0
    case Grid = 1
    case Pin = 2
    case Line = 3
}

protocol SettingsFacet {
    func load()
    func save() throws
    func initialise()
    func cleanup()
}


class SettingsPanel : NSPanel, LaunchableItem {
    static let DefaultsUpdated = Notification.Name("$_LACE_DEFAULTS_UPDATED_EVENT")
    
    
    static var lock = NSLock()
    static var nibname : NSNib.Name = NSNib.Name("Preferences")
    
    static var panel : SettingsPanel? = nil
    static var nib : NSNib?
    
    @IBOutlet weak var tabs: NSTabView!
    @IBOutlet weak var cancel: NSButton!
    @IBOutlet weak var apply: NSButton!
    
    var firstTime : Bool = true
    @IBOutlet weak var drawingView: DrawingView!
    @IBOutlet weak var gridView : GridView!
    @IBOutlet weak var pathsView : PathsView!
    @IBOutlet weak var fontView : FontView!
    //@IBOutlet weak var imagesView: ImagesView!
    
    
    var panels : [SettingsFacet] = []
    
    @IBAction func toolbarAction(_ item: NSToolbarItem) {
        let idx = item.tag
        guard idx>=0, idx<5 else { return }
        tabs?.selectTabViewItem(at: idx)
    }
    
    
    @IBAction func cancelButtonAction(_ button: NSButton) {
        SettingsPanel.close()
    }
    
   
    
    @IBAction func applyButtonAction(_ button: NSButton) {
        do {
            panels.forEach { p in
                do { try p.save() }
                catch(let e) { syslog.error("Error: \(e) while saving defaults") }
            }
            SettingsPanel.close()
            NotificationCenter.default.post(name: SettingsPanel.DefaultsUpdated, object: nil)
        }
        
    }
    
 
    static func launch() -> SettingsPanel? {
        if panel==nil {
            panel=instance()
            panel?.initialise()
            
        }
        panel?.makeKeyAndOrderFront(nil)
    
        return panel
    }
    
    @discardableResult static func close() -> SettingsPanel? {
        panel?.performClose(nil)
        return panel
    }
    
    static func reset() {
        guard panel != nil else { return }
        close()
        panel=nil
    }
    
    func initialise() {
        if firstTime {
            panels = [drawingView,gridView,pathsView,fontView]
            
            panels.forEach { $0.initialise() }
            // do first time round things
            
            //NotificationCenter.default.addObserver(self, selector: #selector(colourChanged(_:)), name: //NSColorPanel.colorDidChangeNotification, object: nil)
            firstTime=false
        }

    }
    

    
    @IBAction func backgroundCallback(_ sender: NSColorWell) {
        sender.color = sender.color.deviceRGB
        syslog.debug("Background colour is now \(sender.color)")
        drawingView.colourEvent(sender)
    }
    
    @IBAction func textCallback(_ sender: NSTextField) {
        syslog.debug("TEXT EVENT")
        drawingView.sizesEvent(sender)
    }
    
}
