//
//  threadTypes.swift
//  lace
//
//  Created by Julian Porter on 10/10/2022.
//

import Foundation

class ThreadKind : CustomStringConvertible {
    
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
    
    
    func setName(_ n : String,_ d : String? = nil) {
        self.name=n
        self.detail=d
    }
    func setCustom() { setName("Custom") }
    
    func setWrapping(_ w : Int) {
        self.wraps=w
    }
    
    var description: String { "\(name) \(detail ?? "")" }
}

protocol IThreads : Sequence where Iterator == Array<String>.Iterator {
    typealias ThreadGroup=[ThreadKind]
    
    
    var threads : [String:ThreadGroup] { get set }
    var groups : [String] { get set }
    
    init(path : URL) throws
    subscript(_ : String) -> ThreadGroup { get }
    var count : Int { get }
    
   
    

}

extension IThreads {
    subscript(_ g : String) -> ThreadGroup { threads[g] ?? [] }
    func makeIterator() -> Iterator { self.groups.makeIterator() }
    var count : Int { groups.count }
    
    
    
}

