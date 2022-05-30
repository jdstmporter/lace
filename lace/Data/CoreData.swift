//
//  CoreData.swift
//  lace
//
//  Created by Julian Porter on 07/05/2022.
//

import Foundation
import SQLite3


struct SQLite3Row {
    var fields : [String:Any?]
    
    init() { fields=[:] }
    
    subscript<T>(_ key : String) -> T? {
        get { fields[key] as? T }
        set { fields[key] = newValue }
    }
    var columns : [String] { Array(fields.keys) }
    var count : Int { fields.count }
}

class SQLite3Loader {
    var db : OpaquePointer
    
    init(path : String) throws {
        var db : OpaquePointer?
        try SQLiteError.wrap(path.withCString { sqlite3_open($0, &db) })
        if let db = db { self.db=db } else { throw SQLiteError.CannotOpenDatabase } 
    }
    convenience init(url: URL) throws {
        try self.init(path: url.path)
    }
    deinit {
        sqlite3_close(self.db)
    }
    
    func processColumn(stmt : inout OpaquePointer,index : Int32) throws -> Any? {
        let t = sqlite3_column_type(stmt, index)
        switch t {
        case SQLITE_INTEGER:
            return sqlite3_column_int(stmt, index)
        case SQLITE_FLOAT:
            return sqlite3_column_double(stmt, index)
        case SQLITE_TEXT:
            guard let utf8=sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: utf8)
        case SQLITE_BLOB:
            guard let blob=sqlite3_column_blob(stmt, index) else { return nil }
            let n=sqlite3_column_bytes(stmt,index)
            return Data.init(bytes: blob, count: numericCast(n))
        case SQLITE_NULL:
            return nil
        default:
            throw SQLiteError.UnknownDataType(t)
        }
    }
    
    func processRow(stmt : inout OpaquePointer) throws -> SQLite3Row {
        var row = SQLite3Row()
        let n = sqlite3_data_count(stmt)
        try (0..<n).forEach { index in
            let name = String(cString: sqlite3_column_name(stmt, index))
            row[name] = try processColumn(stmt: &stmt, index: index)
        }
        return row
    }
    
    func query(sql: String) throws -> [SQLite3Row] {
        var s : OpaquePointer?
        try SQLiteError.wrap(sqlite3_prepare_v2(self.db, sql, -1, &s, nil))
        guard var stmt = s else { throw SQLiteError.CannotPrepareQueryStatement }
        var stop : Bool = false
        var rows = [SQLite3Row]()
        while !stop {
            let result = sqlite3_step(stmt)
            switch result {
            case SQLITE_ROW:
                let row = try processRow(stmt: &stmt)
                rows.append(row)
            case SQLITE_DONE:
                stop=true
            default:
                throw SQLiteError.GeneralError(result)
            }
        }
        sqlite3_finalize(stmt)
        return rows
        
    }
}

class ThreadKind : CustomStringConvertible {
    
    public private(set) var name : String
    public private(set) var  detail : String?
    public private(set) var  wraps : Int
    
    init(name: String="",detail: String? = nil,wraps : Int=12) {
        self.name=name
        self.detail=detail
        self.wraps=wraps
    }
    
    init?(_ row : SQLite3Row) {
        guard let n : String = row["name"] else { return nil }
        self.name=n
        self.detail=row["detail"]
        let w : Int32? = row["windings"]
        self.wraps=numericCast(w ?? 12)
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

class Threads : Sequence {
    
    static let DBName = "threads"
    static let DBExt = "db"
    static let QuerySQL = "select * from threads order by material, name, windings"
    
    typealias ThreadGroup = [ThreadKind]
    var threads : [String:ThreadGroup] = [:]
    var groups : [String] = []
    
    typealias Iterator = Array<String>.Iterator
    
    func add(material : String,thread: ThreadKind) {
        if threads[material]==nil { threads[material]=[] }
        threads[material]?.append(thread)
    }
    
    init() throws  {

            guard let url=URL(resource: Threads.DBName, extension: Threads.DBExt) else { throw DefaultError.CannotGetURL }
            let db=try SQLite3Loader(url: url)
            let rows = try db.query(sql: Threads.QuerySQL)
        
            var gs = Set<String>()
            rows.forEach { row in
                let material : String = row["material"] ?? "unknown"
                if let item = ThreadKind(row) {
                    self.add(material: material, thread: item)
                    gs.insert(material)
                }
            }
            self.groups=Array(gs).sorted()
        
    }
    
    subscript(_ g : String) -> ThreadGroup { threads[g] ?? [] }
    func makeIterator() -> Iterator { self.groups.makeIterator() }
    var count : Int { groups.count }
    
    
    static var the : Threads?
    static func load() -> Threads? {
        if the==nil { the=try? Threads() }
        return the
    }
    static func groups() -> [String] { load()?.groups ?? [] }
    static func group(_ g : String) -> ThreadGroup { load()?[g] ?? [] }
    static func count() -> Int { load()?.count ?? 0 }
    
}



