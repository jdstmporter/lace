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
    
    var path : URL = URL.userHome
    
    func update() {
        DispatchQueue.main.async {
            self.pathView.url = self.path
        }
    }
    
    @IBAction func pathChange(_ obj : Any) {
        let fp = FilePicker(url: self.path, types: [])
        guard fp.runSync(), let dir=fp.dir else { return }
        self.path=dir
        self.update()
    }
    
    func load() {
        do {
            self.path = try LoadSaveFiles.RootPath()
        }
        catch {
            self.path = URL.userHome
        }
        self.update()
    }
    
    func save() throws {
        try Defaults.write("DataDirectory", self.path.path)
        Defaults.remove(forKey: "LastPath")
    }
    
    func initialise() {
        self.load()
    }
    
    func cleanup() {}
    
    
    
    
}
