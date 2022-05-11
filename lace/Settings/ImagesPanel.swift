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
    
    @IBOutlet weak var laceTypes : NSPopUpButton!
    @IBOutlet weak var wrapsPerCM : NSTextField!
    
    @IBAction func resolutionCallback(_ box: NSPopUpButton!) {}
    @IBAction func spacingCallback(_ box: NSTextField!) {}
    
    @IBAction func qualityCallback(_ box: NSTextField!) {}
    
    @IBAction func imageTypeCallback(_ button: NSPopUpButton!) {}
    
    @IBAction func threadsPerCMCallback(_ box: NSTextField!) {}
    @IBAction func laceTypeCallback(_ button: NSPopUpButton!) {}
    
    
    func load() {
        
    }
    
    func save() throws {
        
    }
    
    func initialise() {
        laceTypes.removeAllItems()
        let names = LaceKind.allCases.map { $0.name }
        laceTypes.addItems(withTitles: names)
    }
    
    func cleanup() {
        
    }
    
    
}
