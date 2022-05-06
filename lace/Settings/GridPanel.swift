//
//  GridPanel.swift
//  lace
//
//  Created by Julian Porter on 27/04/2022.
//

import Foundation
import AppKit

enum BoundsError : BaseError {
    case ListInsufficientlyLong
    case CannotFindDefault
}

struct GridBounds {
    
    var minWidth : Int = 1
    var maxWidth : Int = 50
    var minHeight : Int = 1
    var maxHeight : Int = 50
    
    init() {}
    init(from array: [Int]) throws {
        guard array.count>=4 else { throw BoundsError.ListInsufficientlyLong }
        minWidth=array[0]
        minHeight=array[1]
        maxWidth=array[2]
        maxHeight=array[3]
    }
    
    var asArray : [Int] { [minWidth,minHeight, maxWidth,maxHeight] }
    
}
    

class GridView : NSView, SettingsFacet {
    
    @IBOutlet weak var minRows : NSTextField!
    @IBOutlet weak var maxRows : NSTextField!
    @IBOutlet weak var minColumns : NSTextField!
    @IBOutlet weak var maxColumns : NSTextField!
    
    var gridBounds = GridBounds()
    
    func loadGUI() {
        DispatchQueue.main.async { [self] in
            minRows.integerValue=gridBounds.minHeight
            maxRows.integerValue=gridBounds.maxHeight
            minColumns.integerValue=gridBounds.minWidth
            maxColumns.integerValue=gridBounds.maxWidth
        }
    }
    
    @IBAction func fieldCallback(_ field: NSTextField) {
        let m=field.integerValue
        if field==minRows { gridBounds.minHeight=Swift.min(m,gridBounds.maxHeight) }
        if field==maxRows { gridBounds.maxHeight=Swift.max(m,gridBounds.minHeight) }
        if field==minColumns { gridBounds.minWidth=Swift.min(m,gridBounds.maxWidth) }
        if field==maxColumns { gridBounds.maxWidth=Swift.max(m,gridBounds.minWidth) }
        self.loadGUI()
    }
    
    func load() {
        do {
            guard let def : [Int] = (Defaults.get(forKey: "gridBounds"))  else { throw BoundsError.CannotFindDefault }
            self.gridBounds=try GridBounds(from: def)
        } catch {
            syslog.error("Error loading grid bounds: using default")
            self.gridBounds=GridBounds()
        }
        self.loadGUI()
    }
    
    func save() throws {
        let arr = self.gridBounds.asArray
        Defaults.set(forKey: "gridBounds", value: arr)
    }
    
    func initialise() {
        self.gridBounds = GridBounds()
        self.loadGUI()
        
    }
    
    func cleanup() {}
}
