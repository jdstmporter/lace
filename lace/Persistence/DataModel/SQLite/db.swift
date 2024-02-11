//
//  db.swift
//  lace
//
//  Created by Julian Porter on 09/09/2023.
//

import Foundation
import SQLite3

class SQLite3 {
    typealias SQLITE = OpaquePointer
    
    var db : SQLITE
    
    init(path : String) throws {
        var db : SQLITE?
        try SQLiteError.wrap(path.withCString { sqlite3_open($0, &db) })
        if let db = db { self.db=db } else { throw SQLiteError.CannotOpenDatabase }
    }
    convenience init(url: URL) throws {
        try self.init(path: url.path)
    }
    deinit {
        sqlite3_close(self.db)
    }
    
    
}

enum SQLite3Type : CaseIterable {
    case INTEGER
    case FLOAT
    case STRING
    case BINARY
    
    static let values : [Self:Int32] = [
        INTEGER : SQLITE_INTEGER,
        FLOAT : SQLITE_FLOAT,
        STRING : SQLITE_TEXT,
        BINARY : SQLITE_BLOB
    ]
    
    static let names : [Self:String] = [
        INTEGER: "INTEGER",
        FLOAT: "REAL",
        STRING: "TEXT",
        BINARY: "BLOB"
    ]
    
    public var code : Int32 { SQLite3Type.values[self] ?? SQLITE_ERROR }
    public var sql : String { SQLite3Type.names[self] ?? "ERROR" }
    
    public init?(_ n : String) {
        guard let v = (SQLite3Type.allCases.first { $0.sql == n }) else { return nil }
        self=v
    }
    public init?(_ n : Int32) {
        guard let v = (SQLite3Type.allCases.first { $0.code == n }) else { return nil }
        self=v
    }
    
    
}

class SQLite3Row {
    var fields : [String:Any?] = [:]
    
    init() {}
    
    private func column(stmt : inout OpaquePointer,index : Int32) throws -> Any? {
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
    
    func load(stmt : inout OpaquePointer) throws {
        let n=sqlite3_data_count(stmt)
        
        try (0..<n).forEach { index in
            let name = String(cString: sqlite3_column_name(stmt, index))
            let value = try column(stmt: &stmt,index: index)
            fields[name]=value
        }
    }
    
    
    subscript(column: String) -> Any? { get { fields[column] as Any? } set { fields[column] = newValue }}
    
    static func Load(stmt : inout OpaquePointer) throws -> SQLite3Row {
        let row = SQLite3Row()
        try row.load(stmt: &stmt)
        return row
    }
    
}

protocol SQLite3TypeRepresentative : CustomStringConvertible {
    
}
extension Int : SQLite3TypeRepresentative {}
extension Float : SQLite3TypeRepresentative {}
extension String : SQLite3TypeRepresentative {}
extension Data : SQLite3TypeRepresentative {}

struct SQLite3Field : CustomStringConvertible {
    typealias DefType = any SQLite3TypeRepresentative
    var name : String
    var kind : SQLite3Type
    var nonNull : Bool
    var def : DefType?
    
    init(_ name : String,_ kind : SQLite3Type, nonNull: Bool = true, def : DefType? = nil) {
        self.name=name
        self.kind=kind
        self.nonNull=nonNull
        self.def=def
    }
    
    var description: String {
        let nn = (nonNull) ? "NOT NULL" : ""
        let dd = (def != nil) ? "DEFAULT \(def!)" : ""
        return "\"\(name)\"    \(kind.sql) \(nn) \(dd)"
    }
    
    
}

struct SQLite3TableSchema {
    let name : String
    var columns : [SQLite3Field]
    var pk = SQLite3Field("pk",.INTEGER)
    
    static let pkString="PRIMARY KEY(\"pk\" AUTOINCREMENT)"
    
}

class SQLite3Table {
    
}
