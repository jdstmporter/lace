//
//  files.swift
//  lace
//
//  Created by Julian Porter on 05/03/2023.
//

import Foundation

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



