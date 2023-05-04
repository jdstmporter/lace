//
//  prickingSpecifier.swift
//  lace
//
//  Created by Julian Porter on 02/05/2023.
//

import Foundation
import AppKit

class PrickingSpecifier : NSControl {
    
    var pricking = PrickingSpecification()
    
    var isLocked : Bool { false }
    
    @IBAction func createNew(_ sender : Any) {
        guard let w=self.window else { return }
        CreatePrickingWindow.launch(locked: self.isLocked)?.start(host: w, callback: { p in self.cb(p,isNew: true) })
    }
    
    func cb(_ p : PrickingSpecification?,isNew: Bool) {
        self.pricking = p ?? PrickingSpecification()
        guard let s = self.action else { return }
        _ = self.target?.perform(s, with: self)
        
        // get corresponding item from DB or create new
        
    }
    
    
}


class NoStorageView : PrickingSpecifier {
    
    override var isLocked: Bool { true }
    
}


class GotStorageView : PrickingSpecifier, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    @IBOutlet var prickings : NSTableView!
    

    static let cellID = NSUserInterfaceItemIdentifier("Prickings")
    
    

    var data : [PrickingSpecification] = []
    var textFont : NSFont { NSFont.systemFont(ofSize: 10) }
    
    override func awakeFromNib() {
        self.prickings.tableColumns.forEach { column in
            column.headerCell.alignment = .center
            column.width = self.widthFor(column: column)
        }
        //    let x = HeaderView(textCell: column.headerCell.stringValue)
        //    x.alignment = .center
        //    column.headerCell=x
       //}
    }
    
    
    func initialise() {
        data = []
        
        
    }
    
    func getView(row : Int, column: NSTableColumn?) -> NSTextField {
        if let v = prickings.makeView(withIdentifier: GotStorageView.cellID, owner: self) as? NSTextField { return v}
        else {
            let v = NSTextField(labelWithString: "dummy")
            v.font = NSFont.systemFont(ofSize: 10)
            v.identifier = GotStorageView.cellID
            return v
        }
    }
    
    func indexOf(column c: NSTableColumn?) -> Int {
        guard let column=c else { return 0 }
        return prickings.tableColumns.firstIndex(of: column) ?? 0
        
    }
    
    func widthFor(column: NSTableColumn) -> CGFloat {
        let id = column.identifier.rawValue
        let box = self.textFont.boundingRectForFont
        switch id {
        case "width", "height":
            return  2*box.width
        case "kind":
            return  4*box.width
        case "name":
            return  self.prickings.width-8*box.width
        default:
            return 0
        }
    }
    
    // NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int { self.data.count }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let value = self.tableView(tableView, objectValueFor: tableColumn,row: row) else { return nil }
        let view = self.getView(row: row, column: tableColumn)
        view.stringValue="\(value)"
        return view
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let column = tableColumn?.identifier.rawValue else { return nil }
        guard row>=0 && row<data.count  else { return nil }
        
        return data[row][column]
    }
    
    // NSTableViewDelegate
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        false
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat { 16.0 }
    
    
    
    // context menu
    
    @IBAction func contextAction(_ sender: NSMenuItem) {
        let name = sender.title
        switch name {
        case "Open":
            break
        case "Edit":
            break
        case "Delete":
            break
        default:
            break
        }
    }
    
    

    @IBAction func onDoubleClick(_ sender: Any) {
    }
    
    @IBAction func onClick(_ sender: Any) {
        let row = self.prickings.selectedRow
        let pricking = data.at(row)
        self.cb(pricking,isNew: false)
    }
    
}

extension Array {
    
    var range : Range<Int> { 0..<self.count }
    
    func at(_ n : Int) -> Element? { self.range.contains(n) ? self[n] : nil }
}

