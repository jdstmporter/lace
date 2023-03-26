//
//  files.swift
//  lace
//
//  Created by Julian Porter on 05/03/2023.
//

import Foundation

protocol Serialiser {
    associatedtype T : Codable
    
    func url(_ name : String) -> URL
    
    func load(name : String) throws -> T
    @discardableResult func save(_ data : T,name : String) throws -> URL
    
    static func encode(_ item: T) throws -> Data
    static func decode(_ data : Data) throws -> T
}

extension Serialiser {
    
    public func url(_ name: String) -> URL {
        let u = FilePaths()[PathPart.DataDirectory]
        return URL(fileURLWithPath: "\(name).lace", relativeTo: u)
    }
    
    public func load(name : String) throws -> T {
        let d = try Data(contentsOf: self.url(name))
        return try Self.decode(d)
    }
    @discardableResult public func save(_ item : T,name : String) throws -> URL {
        let d = try Self.encode(item)
        let u=self.url(name)
        try d.write(to: u)
        return u
    }
}

public class JSONSerialiser<T> : Serialiser where T : Codable {
    static func encode(_ item: T) throws -> Data {
        let encoder=JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(item)
    }
    
    static func decode(_ data: Data) throws -> T {
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
public class PListSerialiser<T> : Serialiser where T : Codable {
    static func encode(_ item: T) throws -> Data {
        let encoder=PropertyListEncoder()
        encoder.outputFormat = .xml
        return try encoder.encode(item)
    }
    
    static func decode(_ data: Data) throws -> T {
        let decoder=PropertyListDecoder()
        return try decoder.decode(T.self, from: data)
    }
}



struct File {
    
    var url  : URL
    
    init() throws {
        let picker = FileReadPicker(def: FilePaths.root)
        guard picker.runSync() else { throw FileError.CannotPickLoadFile }
        url = picker.url
    }
    
    init(url : URL) { self.url=url }
    
    
    
    func load<T>() throws -> T
    where T : Codable {
        let d = try Data(contentsOf: url)
        let decoder=JSONDecoder()
        return try decoder.decode(T.self, from: d)
    }
    
    @discardableResult func save<T>(_ data : T, compact: Bool=true) throws -> URL
    where T : Codable {
        let encoder=JSONEncoder()
        if !compact { encoder.outputFormatting = .prettyPrinted }
        let d = try encoder.encode(data)
        try d.write(to: url)
        return url
    }
    
    
    
    func del() throws { try FileManager.default.removeItem(at: url) }
    
    var exists : Bool { FileManager.default.fileExists(at: url) }
}



