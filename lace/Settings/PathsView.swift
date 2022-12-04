//
//  PathsView.swift
//  lace
//
//  Created by Julian Porter on 29/04/2022.
//

import Foundation
import AppKit

class PathsView : NSView, SettingsFacet {
    
    @IBOutlet var pathView : NSPathControl!

    var lsf = ViewPaths(.Defaults)
    
    var path : URL { lsf[.LastPath] }
    
    func update() {
        DispatchQueue.main.async {
            self.pathView.url = self.path
        }
    }
    
    @IBAction func pathChange(_ obj : Any) {
        let fp = FilePicker(url: self.path, types: [])
        guard fp.runSync(), let dir=fp.dir else { return }
        self.lsf[.LastPath]=dir
        self.update()
    }
    
    func load() {
        self.update()
    }
    
    func save() throws {
        let p = lsf.readAndClear(.LastPath) ?? URL.def(.LastPath)
        lsf[.DataDirectory]=p.asDirectory()
    }
    
    func initialise() {
        self.load()
    }
    
    func cleanup() {}
    
    
    
    
}
