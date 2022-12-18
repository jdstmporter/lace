//
//  GridPanel.swift
//  lace
//
//  Created by Julian Porter on 27/04/2022.
//

import Foundation
import AppKit



struct GridBounds {
    
    var minWidth : Int = 1
    var maxWidth : Int = 50
    var minHeight : Int = 1
    var maxHeight : Int = 50
    
    init() {}
    init(from array: [Int]) {
        let n=array.count
        if n>0 { minWidth = array[0] }
        if n>1 { minHeight = array[1] }
        if n>2 { maxWidth = array[2] }
        if n>3 { maxHeight = array[3] }
    }
    
    var asArray : [Int] { [minWidth,minHeight, maxWidth,maxHeight] }
    
    func clip(width: Int) -> Int { Swift.min(Swift.max(minWidth,width),maxWidth) }
    func clip(height: Int) -> Int { Swift.min(Swift.max(minHeight,height),maxHeight) }
}

extension ClosedRange<Int> {
    func clamp(_ v : Int) -> Int { Swift.max(self.lowerBound,Swift.min(self.upperBound,v)) }
        
}

enum RangeParts : CaseIterable {
    case Min
    case Max
    case Value
}

struct ValueInRange {
    var parts : [RangeParts:Int]
    
    init(_ mi: Int, _ ma : Int, value: Int) {
        self.parts = [.Min: mi,.Max: ma,.Value: value]
    }
    init() { self.init(1,1,value:1) }
    
    var min : Int {
        get { self[.Min] }
    }
    var max : Int {
        get { self[.Max] }
    }
    var value : Int {
        get { self[.Value] }
    }
    
    subscript(_ part: RangeParts) -> Int {
        get { self.parts[part] ?? 1 }
        set { self.parts[part]=newValue }
    }
    
    var isValid : Bool { self[.Min]<self[.Value] && self[.Value]<=self[.Max] }
}

extension ValueInRange : EncDec {
    public static func dec(x: Any) -> ValueInRange? {
        guard let cpts = x as? [Int] else { return nil }
        guard cpts.count == 3 else { return nil }
        return ValueInRange(cpts[0],cpts[1],value: cpts[2])
    }
    public func enc() -> Any? { [self.min,self.value,self.max] }
}
extension ValueInRange : Nameable, HasDefault {
    public static var zero: ValueInRange { ValueInRange() }
    public static func def(_ v : ViewPart) -> ValueInRange { zero }
    public var str : String { "\(min):\(value):\(max)"}
    
}
   

class GridView : NSView, SettingsFacet {
    
    @IBOutlet weak var minRows : NSTextField!
    @IBOutlet weak var maxRows : NSTextField!
    @IBOutlet weak var minColumns : NSTextField!
    @IBOutlet weak var maxColumns : NSTextField!
    
    @IBOutlet weak var defaultRows : NSTextField!
    @IBOutlet weak var defaultColumns : NSTextField!
    
    var dW : Int = 1
    var dH : Int = 1
    
    var gridBounds = GridBounds()
    
    func loadGUI() {
        DispatchQueue.main.async { [self] in
            minRows.integerValue=gridBounds.minHeight
            maxRows.integerValue=gridBounds.maxHeight
            minColumns.integerValue=gridBounds.minWidth
            maxColumns.integerValue=gridBounds.maxWidth
            
            defaultRows.integerValue=dH
            defaultColumns.integerValue=dW
        }
    }
    
    @IBAction func fieldCallback(_ field: NSTextField) {
        let m=field.integerValue
        if field==minRows { gridBounds.minHeight=Swift.min(m,gridBounds.maxHeight) }
        if field==maxRows { gridBounds.maxHeight=Swift.max(m,gridBounds.minHeight) }
        if field==minColumns { gridBounds.minWidth=Swift.min(m,gridBounds.maxWidth) }
        if field==maxColumns { gridBounds.maxWidth=Swift.max(m,gridBounds.minWidth) }
        if field==defaultRows { dH = gridBounds.clip(height: m) }
        if field==defaultColumns { dW = gridBounds.clip(width: m) }
        self.loadGUI()
    }
    
    func load() {
        do {
            guard let def : [Int] = (Defaults.get(forKey: "gridBounds"))  else { throw DefaultError.CannotFindDefault }
            self.gridBounds=GridBounds(from: def)
        } catch {
            syslog.error("Error loading grid bounds: using default")
            self.gridBounds=GridBounds()
        }
        self.dW = Defaults.get(forKey: "GridSize-width") ?? 1
        self.dH = Defaults.get(forKey: "GridSize-height") ?? 1
        self.loadGUI()
    }
    
    func save() throws {
        let arr = self.gridBounds.asArray
        Defaults.set(forKey: "gridBounds", value: arr)
        Defaults.set(forKey: "GridSize-width", value: dW)
        Defaults.set(forKey: "GridSize-hight", value: dH)
    }
    
    func initialise() {
        self.gridBounds = GridBounds()
        self.dW=1
        self.dH=1
        self.loadGUI()
        
    }
    
    func cleanup() {}
}
