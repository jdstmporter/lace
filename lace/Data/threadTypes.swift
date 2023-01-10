//
//  threadTypes.swift
//  lace
//
//  Created by Julian Porter on 10/10/2022.
//

import Foundation


class ThreadKind : CustomStringConvertible, Comparable {
    static func < (lhs: ThreadKind, rhs: ThreadKind) -> Bool {
        (lhs.name<rhs.name) ||
        (lhs.name==rhs.name && lhs.wraps<rhs.wraps) ||
        (lhs.name==rhs.name && lhs.wraps==rhs.wraps && (lhs.detail ?? "") < (rhs.detail ?? ""))
    }
    static func == (lhs: ThreadKind, rhs: ThreadKind) -> Bool {
        lhs.array==rhs.array
    }
    
    
    public private(set) var name : String
    public private(set) var  detail : String?
    public private(set) var  wraps : Int
    
    init(name: String="",detail: String? = nil,wraps : Int=12) {
        self.name=name
        self.detail=detail
        self.wraps=wraps
    }
    
    
    
    init?(_ row : [String:Any]) {
        guard let name = row["name"] as? String else { return nil }
        self.name=name
        self.detail = row["detail"] as? String
        self.wraps = (row["windings"] as? Int) ?? 12
    }
    
    subscript(_ key: String) -> CustomStringConvertible {
        switch key {
        case "name" :
            return self.name
        case "detail" :
            return self.detail ?? ""
        case "wraps" :
            return self.wraps
        default:
            return ""
        }
    }
    
    
    func setName(_ n : String,_ d : String? = nil) {
        self.name=n
        self.detail=d
    }
    func setCustom() { setName("Custom") }
    
    func setWrapping(_ w : Int) {
        self.wraps=w
    }
    
    var description: String { "\(name) \(detail ?? "")" }
    
    var array : [String] { [name, detail ?? "", wraps.str] }
}

struct FullThreadKind {
    public private(set) var thread: ThreadKind
    public private(set) var material : String
    
    init(material: String,thread : ThreadKind) {
        self.material=material
        self.thread=thread
    }
    subscript(_ key: String) -> CustomStringConvertible {
        if key=="material" { return self.material}
        else { return self.thread[key] }
    }
    var strings : [String] { [material, thread.name, thread.detail ?? "", thread.wraps.str] }
    
    
    
}

protocol IThreads : Sequence where Iterator == Array<String>.Iterator {
    typealias ThreadGroup=[ThreadKind]
    
    
    var threads : [String:ThreadGroup] { get set }
    var groups : [String] { get set }
    
    var list : [FullThreadKind] { get }
    
    init(path : URL) throws
    subscript(_ : String) -> ThreadGroup { get }
    var count : Int { get }
    
   
    

}

extension IThreads {
    subscript(_ g : String) -> ThreadGroup { threads[g] ?? [] }
    func makeIterator() -> Iterator { self.groups.makeIterator() }
    var count : Int { groups.count }
    
    var list : [FullThreadKind] {
        let l : [[FullThreadKind]] = groups.map  { material in
            let t=self.threads[material] ?? []
            return t.map { FullThreadKind(material: material, thread: $0) }
        }
        return Array(l.joined())
    }
    
    
    
}

