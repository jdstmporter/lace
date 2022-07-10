//
//  CSV.swift
//  lace
//
//  Created by Julian Porter on 10/07/2022.
//

import Foundation
import TabularData

class CSVLoader : IThreads {
    typealias Row = DataFrame.Row
    
    static let NILs = Set([""])
    static let TRUEs = Set(["true"])
    static let FALSEs = Set(["false"])
    static let types : [String:CSVType] = ["material": .string,
                                    "name": .string,
                                    "detail": .string,
                                    "wraps" : .integer]
    static let readOptions = CSVReadingOptions(hasHeaderRow: true, nilEncodings: NILs, trueEncodings: TRUEs, falseEncodings: FALSEs, floatingPointType: .double, ignoresEmptyLines: true, usesQuoting: true, usesEscaping: true)
    
    static let DetailColumn = ColumnID.init("detail", String.self)
    static let NameColumn = ColumnID.init("name", String.self)


    var groups : [String] = []
    var threads : [String:[ThreadKind]] = [:]

    required init(path : URL) throws {
        let g=try DataFrame(contentsOfCSVFile: path,
                            columns: nil, rows: nil, types: CSVLoader.types,
                            options: CSVLoader.readOptions).sorted(on: CSVLoader.NameColumn, CSVLoader.DetailColumn, order: .ascending)
        let mats = Set(g.rows.compactMap { $0["material",String.self] })
        var thr = [String:[ThreadKind]]()
        mats.forEach { thr[$0]=[] }
        mats.forEach { m in
            let chunk=g.rows.filter { $0["material",String.self]==m }
            thr[m]=chunk.compactMap { ThreadKind($0) }
        }
        self.groups=Array(mats).sorted()
        self.threads=thr
    }
    
    convenience init(path: String) throws {
        try self.init(path: URL(fileURLWithPath: path))
    }
    
    convenience init() throws  {
        guard let url = Bundle.main.url(forResource: "threads", withExtension: "csv") else { throw LaceError.CannotFindThreadsCSV  }
        try self.init(path: url)
    }
    
    static var the : CSVLoader?
    
    static func load() -> CSVLoader? {
        if the==nil { the=try? CSVLoader() }
        return the
    }
    static func groups() -> [String] { load()?.groups ?? [] }
    static func group(_ g : String) -> ThreadGroup { load()?[g] ?? [] }
    static func count() -> Int { load()?.count ?? 0 }
    
}
