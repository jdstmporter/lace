//
//  JSON.swift
//  lace
//
//  Created by Julian Porter on 09/07/2022.
//

import Foundation

enum JSONError : Error {
    case FileError(Error)
}

class JSONThread : Codable, CustomStringConvertible, Comparable {
    
    internal var slug : String { "\(material).\(name).\(detail).\(wraps)"}
    
    static func < (lhs: JSONThread, rhs: JSONThread) -> Bool {
        lhs.slug<rhs.slug
    }
    
    static func == (lhs: JSONThread, rhs: JSONThread) -> Bool {
        lhs.slug==rhs.slug
    }
    
    public var material : String
    public var name : String
    public var  detail : String
    public var  wraps : Int
    
    init() {
        material=""
        name=""
        detail=""
        wraps=12
    }
    
    var description: String { "\(name) \(detail)" }
    
}
class JSONThreads : Codable, Sequence {
    public typealias Element = JSONThread
    public typealias Iterator = Array<Element>.Iterator
    public var items : [JSONThread]
    
    init() {
        items=[]
    }
    var count : Int { items.count }
    func makeIterator() -> Array<Element>.Iterator { items.makeIterator() }
    
   
        
    
    
}

class JSONLoader {
    
    
    let materials : [String]
    let threads : [String : [JSONThread]]
    
    init(path: String) throws {
        do {
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url, options: .uncached)
            let json = try JSONDecoder().decode(JSONThreads.self, from: data)
            
            let m = Set(json.map { $0.material })
            self.materials=m.sorted()
            
            var ts : [String : [JSONThread]] = [:]
            m.forEach { material in
                let t = json.filter { $0.material==material }
                ts[material] = t.sorted()
            }
            self.threads=ts
        }
        catch(let e) {
            throw JSONError.FileError(e)
        }
    }
}
