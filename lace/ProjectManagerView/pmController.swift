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



class ProjectManagerController : NSViewController, NSTabViewDelegate {
    
    enum Tabs : CaseIterable {
        case Loading
        case Success
        case Failure
        
        static let _map : [DataState:Tabs] = [
            .Unset : .Loading,
            .Good : .Success,
            .Bad : .Failure
        ]
        
        init(from d: DataState) {
            self = Tabs._map[d] ?? .Loading
        }
        init(_ name : String) {
            self = (Self.allCases.first { $0.label==name }) ?? .Loading
        }
        var label : String { "\(self)" }
    }
    
    
    @IBOutlet weak var tabs: NSTabView!
    
    var dataState = Trivalent<DataHandler>()
    var handler : DataHandler? = nil
    var initialised : Bool = false
    var prickings : [PrickingSpecification] = []
    
    func setTab(_ state : DataState = .Unset) {
        self.tabs.selectTabViewItem(at: state.rawValue)
        self.initialised = state != .Unset
        self.reload()
        (self.tabs.tabViewItems[state.rawValue].view as? PrickingSpecifier)?.loadData(prickings)
    }
    
    func setActiveMode(state: DataState) async {
        await MainActor.run {
            guard !self.initialised else { return }
            self.setTab(state)
        }
    }
    
    func reload() {
        if let handler=self.handler {
            var d : [PrickingData] = (try? handler.getAll()) ?? []
            self.prickings = d.map { PrickingSpecification($0) }
        }
        else {
            self.prickings=[]
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
        guard idx != NSNotFound else { return }
        
        
    }
    
    func save(_ item : PrickingSpecification) throws {
        guard let handler=self.handler else { return }
        let obj : PrickingData = try handler.getOrCreate { $0.uid==item.uid }
        item.asData(obj)
    }
    
    @IBAction func actionResponse(_ from: Any) {
        // redo this with an enum
        guard let view=self.tabs.selectedTabViewItem?.view as? PrickingSpecifier else { return }
        
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


