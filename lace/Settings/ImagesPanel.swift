//
//  ImagesPanel.swift
//  lace
//
//  Created by Julian Porter on 06/05/2022.
//

import Foundation
import AppKit

extension Float {
    func truncated(nDecimals: Int = 1) -> Float {
        let factor : Float = (0..<nDecimals).reduce(1.0) { (res,_) in 10.0*res }
        let rnd = (self*factor).rounded()
        return Float(rnd)/factor
    }
}

enum LaceStyle : CaseIterable {
    case Milanese
    case Bedfordshire
    case PointGround
    case Bruges
    case Torchon
    case Valenceniennes
    case Binche
    case Flanders

    static let windings : [LaceStyle:Int] = [
        .Milanese : 8,
        .Bedfordshire : 9,
        .PointGround : 10,
        .Bruges : 11,
        .Torchon : 12,
        .Valenceniennes : 16,
        .Flanders : 18,
        .Binche : 18
    ]
    static let names : [LaceStyle:String] = [
        .Milanese : "Milanese",
        .Bedfordshire : "Bedfordshire",
        .PointGround : "Point Ground",
        .Bruges : "Bruges",
        .Torchon : "Torchon",
        .Valenceniennes : "Valenceniennes",
        .Flanders : "Flanders",
        .Binche : "Binche"
    ]
    
    var name : String { LaceStyle.names[self] ?? "" }
    var wrapsPerSpace : Int { LaceStyle.windings[self] ?? 12 }
    
    init?(_ n : String) {
        guard let x = (LaceStyle.allCases.first { $0.name == n }) else { return nil }
        self = x
    }
    
    func pinSpacingInMM(wrapsPerCM: Int) -> Float {
        let raw = 10.0*Float(self.wrapsPerSpace)/Float(wrapsPerCM)
        return raw.truncated(nDecimals: 1)
    }
    
    
    
}

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
        let names = LaceStyle.allCases.map { $0.name }
        laceTypes.addItems(withTitles: names)
    }
    
    func cleanup() {
        
    }
    
    
}
