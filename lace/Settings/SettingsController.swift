//
//  SettingsController.swift
//  lace
//
//  Created by Julian Porter on 16/04/2022.
//

import Foundation
import AppKit

class SettingsController : NSViewController {}


class SettingsPanel : NSPanel, LaunchableItem {
    
    static var lock = NSLock()
    static var nibname : NSNib.Name = NSNib.Name("Preferences")
    
    static var panels : [UUID : SettingsPanel] = [:]
    static var nib : NSNib?
    
    
    
    static func launch(uid: UUID) -> SettingsPanel? {
        var panel : SettingsPanel? = panels[uid]
        if panel == nil {
            panel=instance()
            panels[uid]=panel
        }
        
        panel?.makeKeyAndOrderFront(nil)
        
        return panel
    }
    
    static func close(uid: UUID) -> SettingsPanel? {
        let panel=panels[uid]
        panel?.performClose(nil)
        return panel
    }
}
