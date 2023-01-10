//
//  PLIST.swift
//  lace
//
//  Created by Julian Porter on 09/10/2022.
//

import Foundation



enum PListErrors : Error {
    case cannotLoadThreadsFile
}


class Threads : IThreads, Sequence {
    
    
    static let PListName = "threads"
    static let PListExt = "plist"
    
    var threads : [String:ThreadGroup] = [:]
    var groups : [String] = []
    
    func add(material : String,thread: ThreadKind) {
        if threads[material]==nil { threads[material]=[] }
        threads[material]?.append(thread)
    }
    
    convenience init() throws  {
            guard let url=URL(resource: Self.PListName, extension: Self.PListExt) else { throw DefaultError.CannotGetURL }
        try self.init(path: url)
    }
    
    required init(path: URL) throws {
        
        guard let arr = NSArray(contentsOf: path) else { throw PListErrors.cannotLoadThreadsFile }
        let plist : [[String:Any]] = arr.compactMap { r in
            guard let row = r as? [String:Any] else { return nil }
            return row
        }
            
        var gs = Set<String>()
        plist.forEach { row in
            let material : String = (row["material"] as? String) ?? "unknown"
            if let item = ThreadKind(row) {
                self.add(material: material, thread: item)
                gs.insert(material)
            }
        }
        self.groups=Array(gs).sorted()
        self.groups.forEach { self.threads[$0]?.sort() }
        
    }
    

    
    static var the : Threads?
    static func load() -> Threads? {
        if the==nil { the=try? Threads() }
        return the
    }
    static func groups() -> [String] { load()?.groups ?? [] }
    static func group(_ g : String) -> ThreadGroup { load()?[g] ?? [] }
    static func count() -> Int { load()?.count ?? 0 }
    
}
