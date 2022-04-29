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
    
    var path : String = ""
    
    func update() {
        DispatchQueue.main.async {
            self.pathView.url = URL(fileURLWithPath: self.path, isDirectory: true)
        }
    }
    
    @IBAction func pathChange(_ obj : Any) {
        let fp = FilePicker(def: self.path, types: [])
        guard fp.runSync(), let dir=fp.dir else { return }
        self.path=dir
        self.update()
    }
    
    func load() {
        do {
            self.path = try LoadSaveFiles.RootPath().path
        }
        catch {
            self.path = URL.userHome.path
        }
        self.update()
    }
    
    func save() throws {
        Defaults.setString(forKey: "DataDirectory", value: self.path)
        Defaults.remove(forKey: "LastPath")
    }
    
    func initialise() {
        self.load()
    }
    
    
    
    
}
