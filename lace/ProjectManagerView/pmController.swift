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
    
    
    @IBOutlet weak var tabs: NSTabView!
    
    var dataState = Trivalent<DataHandler>()
    var initialised : Bool = false
    
    func setTab(_ state : DataState = .Unset) {
        self.tabs.selectTabViewItem(at: state.rawValue)
        self.initialised = state != .Unset
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
            await self.setActiveMode(state: state)
        }
    }
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let item = tabViewItem else { return }
        let idx = self.tabs.indexOfTabViewItem(item)
        guard idx != NSNotFound else { return }
        
        
    }
    
    @IBAction func actionResponse(_ from: Any) {
        guard let view=self.tabs.selectedTabViewItem?.view else { return }
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


