//
//  ImagesPanel.swift
//  lace
//
//  Created by Julian Porter on 06/05/2022.
//

import Foundation
import AppKit

class ImagesView : NSView, SettingsFacet {
    
    @IBOutlet weak var resolutionBox : NSPopUpButton!
    @IBOutlet weak var spacingBox : NSTextField!
    @IBOutlet weak var imageFormat : NSPopUpButton!
    @IBOutlet weak var imageQuality : NSTextField!
    
    @IBAction func resolutionCallback(_ box: NSPopUpButton!) {}
    @IBAction func spacingCallback(_ box: NSTextField!) {}
    
    @IBAction func qualityCallback(_ box: NSTextField!) {}
    
    @IBAction func imageTypeCallback(_ button: NSPopUpButton!) {}
    
    
    func load() {
        <#code#>
    }
    
    func save() throws {
        <#code#>
    }
    
    func initialise() {
        <#code#>
    }
    
    func cleanup() {
        <#code#>
    }
    
    
}
