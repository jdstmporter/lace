//
//  CoreData.swift
//  lace
//
//  Created by Julian Porter on 07/05/2022.
//

import Foundation
import CoreData

class ThreadKind {
    
    let name : String
    let detail : String?
    let wraps : Int
    
    init(name: String,detail: String? = nil,wraps : Int) {
        self.name=name
        self.detail=detail
        self.wraps=wraps
    }
    
    init?(_ element: XMLElement) {
        
        guard let n=element.elements(forName: "name").first?.stringValue else { return nil }
        self.name=n
        self.detail=element.elements(forName: "detail").first?.stringValue
        guard let w=element.elements(forName: "wraps").first?.stringValue else { return nil }
        self.wraps=Int(w) ?? 12
    }
}


class ThreadLibrary : Sequence {
    
    static let RepositoryName = "threads"
    static let RepositoryExt = "xml"
    
    typealias ThreadGroup = [ThreadKind]
    var threads : [String:ThreadGroup] = [:]
    var groups : [String] = []
    
    typealias Iterator = Array<String>.Iterator
    
    func add(material : String,thread: ThreadKind) {
        if threads[material]==nil { threads[material]=[] }
        threads[material]?.append(thread)
    }
    
    init() throws {
        guard let url=URL(resource: ThreadLibrary.RepositoryName, extension: ThreadLibrary.RepositoryExt) else { throw DefaultError.CannotGetURL }
        let doc=try XMLDocument(contentsOf: url)
        guard let root=doc.rootElement() else { throw DefaultError.DocumentHasNoRoot }
        
        var gs = Set<String>()
        root.elements(forName: "group").forEach { group in
            if let material=group.attribute(forName: "material")?.stringValue {
                gs.insert(material)
                let ts = group.elements(forName: "thread").compactMap { ThreadKind($0) }
                ts.forEach { self.add(material: material, thread: $0) }
            }
        }
        self.groups=Array(gs).sorted()
    }
    
    subscript(_ g : String) -> ThreadGroup { threads[g] ?? [] }
    func makeIterator() -> Iterator { self.groups.makeIterator() }
    var count : Int { groups.count }
    
}


class ThreadSet {
    private static let dataModel : String = "LaceDataModel"
    public static let ThreadsAreLoaded = Notification.Name("ThreadDataBasIsLoaded$")
    
    public enum Status {
        case Waiting
        case Loading
        case Loaded
        case Unavailable
    }
    var status : Status = .Waiting
    var threads : [ThreadLib] = []
    
    init() {
        let container = NSPersistentContainer.init(name: ThreadSet.dataModel)
        container.loadPersistentStores() { (description, error) in
            do {
                guard error==nil else { throw error! }

                let request = NSFetchRequest<DThreadType>()
                let records = try container.viewContext.fetch(request)
                self.threads = records.compactMap { ThreadLib($0) }
                self.status = .Loaded
                NotificationCenter.default.post(name: ThreadSet.ThreadsAreLoaded, object: nil)
            }
            catch(let e) {
                self.status = .Unavailable
                self.threads = []
                syslog.error("\(e)")
            }
        }
        
    }
}
