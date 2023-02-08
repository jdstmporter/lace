//
//  fileBased.swift
//  lace
//
//  Created by Julian Porter on 06/02/2023.
//

import Foundation

struct AutoBackup : DataStorage {
    
    static let name : String = "lace.bak.json"
    var url  : URL
    
    init()  {
        var p = FilePaths.autosave
        p.appendPathComponent(AutoBackup.name)
        url = p
    }
    
    func backup(_ p : Pricking) {
        do { try self.save(p,compact: true) } catch {}
    }
    func restore() -> Pricking? {
        try? self.load()
    }
    func new() {
        if self.exists {
            do { try self.del() } catch {}
        }
    }

}
