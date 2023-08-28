//
//  popoverWindow.swift
//  lace
//
//  Created by Julian Porter on 22/04/2023.
//

import Foundation
import AppKit

enum ActionChoice {
    case Continue
    case Load(url : URL?)
    case New(width: Int,height: Int)

    case Undefined
}

extension NSRect {
    var lb : NSPoint { NSPoint(x: self.minX, y: self.minY) }
    var lt : NSPoint { NSPoint(x: self.minX, y: self.maxY) }
    var rb : NSPoint { NSPoint(x: self.maxX, y: self.minY) }
    var rt : NSPoint { NSPoint(x: self.maxX, y: self.maxY) }
}
class HeaderView : NSTableHeaderCell {
    
    var borderColour : NSColor {
        NSColor.black
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        self.borderColour.setStroke()
        let p1 = NSBezierPath(from: cellFrame.lt, to: cellFrame.rt)
        let p2 = NSBezierPath(from: cellFrame.rb, to: cellFrame.rt)

        [p1, p2].forEach { p in
            p.lineWidth=0
            p.stroke()
        }
        
        self.drawInterior(withFrame: cellFrame, in: controlView)
    }

}

extension Pricking {
    init(_ dp : DataPricking) {
        let grid = dp.getGrid()
        self.init(name: dp.name ?? "Default",kind: dp.laceKind,grid: grid)
    }
}

class ProjectManagerController : NSViewController, NSTabViewDelegate {
    
    @IBOutlet weak var tabs: NSTabView!
    var selected : DataState = .Unset
    
    var dataState = Trivalent<DataHandler>()
    var handler : DataHandler? = nil
    var initialised : Bool = false
    var prickings : [Pricking] = []
    
    private func specifier(_ spec : DataState) -> PrickingSpecifier? {
        self.tabs.tabViewItems[spec.rawValue].view as? PrickingSpecifier
    }
    
    func reload() {
        if let handler=self.handler {
            let d : [DataPricking] = (try? handler.getAll()) ?? []
            self.prickings = d.compactMap { Pricking($0) }
        }
        else { self.prickings=[] }
    }
    
    func save(_ item : Pricking) throws {
        guard let handler=self.handler else { return }
        var obj : DataPricking = try handler.getOrCreate { $0.uuid==item.uuid }
        item.update(obj)
        handler.commit()
    }
    func delete(_ item : Pricking) {
        guard let handler=self.handler else { return }
        handler.delete(DataPricking.self) { $0.uuid==item.uuid }
        handler.commit()
    }
    
    func setTab(_ state : DataState = .Unset) {
        self.selected = state
        self.tabs.selectTabViewItem(at: self.selected.rawValue)
        self.initialised = self.selected != .Unset
        self.reload()
        self.specifier(self.selected)?.loadData(prickings)
    }
    
    func setActiveMode(state: DataState) async {
        await MainActor.run {
            guard !self.initialised else { return }
            self.setTab(state)
        }
    }
    
    
    
    func setDataSource(handler: DataHandler?) {
        Task {
            let state = await self.dataState.set(handler)
            self.handler=await self.dataState.obj
            await self.setActiveMode(state: state)
        }
    }
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let item = tabViewItem else { return }
        let idx = self.tabs.indexOfTabViewItem(item)
        guard idx != NSNotFound, let tab = DataState(rawValue: idx) else { return }
        self.selected = tab
    }
    
    
    
    
    @IBAction func actionResponse(_ from: Any) {
        // redo this with an enum
        guard let view=self.specifier(self.selected) else { return }
        
        let persist = !view.isLocked
        let specifier = view.pricking
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: SettingsPanel.DefaultsUpdated, object: nil)
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        Task {
            let state = await dataState.state
            await self.setActiveMode(state: state)
        }
    }
    
    @objc func updateEvent(_ n : Notification) {
        DispatchQueue.main.async {
            syslog.info("Reloading defaults")
            
        }
    }
}


