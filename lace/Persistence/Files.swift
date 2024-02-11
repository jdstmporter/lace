//
//  Files.swift
//  lace
//
//  Created by Julian Porter on 23/07/2023.
//

import Foundation


class FileService {
    struct RootError : Error {}
    
    static var FM : FileManager { FileManager.default }
    static var appName : String { Bundle.appName ?? "LaceApp" }
    public private(set) static var root : URL = URL.zero
    static var paths : [URL]=[]
    
    static func initialiseDataDirectory(app: String) throws -> URL {
        var path = try FM.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        path.appendPathComponent(app)
        try FM.createDirectory(at: path, withIntermediateDirectories: true)
        return path
    }
    
    @discardableResult static func enumerate<T>(as typ: T.Type) -> [URL] where T : Codable {
        do {
            self.root = try self.initialiseDataDirectory(app: self.appName)
            if self.root == URL.zero { throw RootError() }
            let paths = try FM.contentsOfDirectory(at: self.root, includingPropertiesForKeys: nil)
            self.paths = paths.filter { self.isLoadable(as: typ,at: $0) }
        }
        catch(let e) {
            syslog.error(e.localizedDescription)
            self.paths = []
        }
        return self.paths
    }
    
    static func url(for name: String) -> URL { self.root.appendingPathComponent(name) }
    
    static func exists(at url: URL) -> Bool { FM.fileExists(at: url) }
    static func isLoadable<T>(as: T.Type,at url: URL) -> Bool where T : Codable {
        guard self.exists(at: url) else { return false }
        do {
            let _ : T = try self.load(at: url)
            return true
        }
        catch { return false }
    }
    
    static func load<T>(at url: URL) throws -> T
    where T : Codable {
        let d = try Data(contentsOf: url)
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    @discardableResult static func save<T>(at url: URL,data : T, compact: Bool=true) throws -> URL
    where T : Codable {
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        let d = try encoder.encode(data)
        try d.write(to: url)
        return url
    }
    
    
    
    static func del(at url: URL) throws { try FM.removeItem(at: url) }
    
}





protocol Storable : Codable {
    
    var name : String { get }
    var url : URL { get }
    
    static func load(_ name : String) throws -> Self
    @discardableResult func save() throws -> URL
    func del() throws
    
    func isLoadable() -> Bool
}

extension Storable {
    
    var url : URL { FileService.url(for: self.name) }
    
    static func load(_ name : String) throws -> Self { try FileService.load(at: FileService.url(for: name)) }
    @discardableResult func save() throws -> URL { try FileService.save(at: self.url, data: self) }
    func del() throws { try FileService.del(at: self.url) }
    func isLoadable() -> Bool { FileService.isLoadable(as: Self.self, at: self.url) }
    
    
}




    
    
    
    
    
        
    

