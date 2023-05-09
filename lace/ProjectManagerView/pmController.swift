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

class ProjectDataManager : Sequence {
    typealias Element = PrickingSpecification
    typealias Iterator = Array<Element>.Iterator
    
    var handler : DataHandler
    
    
    init?(_ handler : DataHandler?) {
        guard let handler=handler else { return nil }
        self.handler=handler
    }
    
    var data : [PrickingData] { (try? self.handler.getAll()) ?? [] }
    var prickings : [PrickingSpecification] { self.data.map { $0.copy() } }
    var count : Int { self.data.count }
    func makeIterator() -> Array<Element>.Iterator { self.prickings.makeIterator() }
    subscript(_ idx : Int) -> PrickingSpecification { self.prickings[idx] }
    
    func save(_ item : PrickingSpecification) throws {
        let obj : PrickingData = try self.handler.getOrCreate { $0.uid==item.uid }
        obj.copy(item)
    }
    func load(_ item : PrickingSpecification) throws -> PrickingData? {
        try self.handler.getAll().first { $0.uid == item.uid }
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
    var dataManager : ProjectDataManager?
    var initialised : Bool = false
    
    func setTab(_ state : DataState = .Unset) {
        self.tabs.selectTabViewItem(at: state.rawValue)
        self.initialised = state != .Unset
        let prickings = self.dataManager?.prickings ?? []
        (self.tabs.tabViewItems[state.rawValue].view as? PrickingSpecifier)?.loadData(prickings)
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
            self.dataManager=await ProjectDataManager(self.dataState.obj)
            await self.setActiveMode(state: state)
        }
    }
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let item = tabViewItem else { return }
        let idx = self.tabs.indexOfTabViewItem(item)
        guard idx != NSNotFound else { return }
        
        
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


