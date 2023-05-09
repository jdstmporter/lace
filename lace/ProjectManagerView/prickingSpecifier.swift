//
//  prickingSpecifier.swift
//  lace
//
//  Created by Julian Porter on 02/05/2023.
//

import Foundation
import AppKit



extension NSTableColumn {
    var prickingElement : Columns { Columns(self.identifier.rawValue) }
}

extension PrickingSpecification {
    func format(for c: Columns) -> String {
        switch c {
        case .name:
            return self.name
        case .width:
            return "\(self.width)"
        case .height:
            return "\(self.height)"
        case .kind:
            return  self.kind.str
        default:
            return "-"
        }
    }
    
    
}

class PrickingSpecifier : NSControl {
    
    
    var pricking = PrickingSpecification()
    
    var isLocked : Bool { false }
    func loadData(_ d : [PrickingSpecification]) {}
    
    @IBAction func createNew(_ sender : Any) {
        Task {
            guard let w=self.window, let popup = CreatePrickingWindow.launch(locked: self.isLocked) else { return }
            do {
                let p = try await popup.start(host: w)
                self.processRequest(p, isNew: true)
            }
            catch(let e as CreatePrickingWindow.PrickingError) {
                if e == .cancelled { syslog.info("Cancelled creation") }
                else { syslog.info("Unknown error") }
            }
        }
    }
    
    
    
    func processRequest(_ p : PrickingSpecification?,isNew: Bool) {
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
    static let NonName : [Columns] = [.width,.height,.kind]

    var data : [PrickingSpecification] = []
    var widths : [Columns:CGFloat] = [:]
    var textFont : NSFont { NSFont.systemFont(ofSize: 10) }
 
    func textSize(_ str : String) -> NSSize {
        let attr = [NSAttributedString.Key.font : self.textFont]
        return (str as NSString).size(withAttributes: attr)
        
    }
    
    func widthFor(column: NSTableColumn) -> CGFloat {
        let id = column.prickingElement
        let w = self.prickings.width
        if Self.NonName.firstIndex(of: id) != nil {
            return self.widths[id] ?? 0
        }
        else if id == .name {
            var ww : CGFloat = 0
            Self.NonName.forEach { ww = ww + (self.widths[$0] ?? 0) }
            return w - ww
        }
        else { return 0 }
        
    }
    
    override func awakeFromNib() {
        
        widths.removeAll()
        widths[.width] = self.textSize("1000").width
        widths[.height] = self.textSize("1000").width
        widths[.kind] = LaceKind.allCases.map { self.textSize($0.name).width }.max() ?? 1.0
        
        self.prickings.tableColumns.forEach { column in
            column.headerCell.alignment = .center
            let w = self.widthFor(column: column)
            print("\(column) : \(w)")
            //column.width = w
        }
        
    }
    
    
    func initialise() {
        //data = []
    }
    
    override func loadData(_ d : [PrickingSpecification]) {
        self.data=d
        Task {
            await MainActor.run { self.prickings.reloadData() }
        }
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
        return column.prickingElement.idx
        
    }

    // NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int { self.data.count }
    func tableView(_ tableView: NSTableView, viewFor column: NSTableColumn?, row: Int) -> NSView? {
        guard let value = self.tableView(tableView, objectValueFor: column,row: row) else { return nil }
        let view = self.getView(row: row, column: column)
        view.stringValue="\(value)"
        return view
    }
    func tableView(_ tableView: NSTableView, objectValueFor column: NSTableColumn?, row: Int) -> Any? {
        guard let column = column else { return nil }
        guard row>=0 && row<data.count  else { return nil }
        
        return data[row][column.prickingElement]
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
    
    // table actions

    @IBAction func onDoubleClick(_ sender: Any) {
    }
    
    @IBAction func onClick(_ sender: Any) {
        let row = self.prickings.selectedRow
        let pricking = data.at(row)
        self.processRequest(pricking,isNew: false)
    }
    
}

extension Array {
    
    var range : Range<Int> { 0..<self.count }
    
    func at(_ n : Int) -> Element? { self.range.contains(n) ? self[n] : nil }
}

