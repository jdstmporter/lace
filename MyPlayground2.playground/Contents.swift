import Cocoa
import TabularData

class ThreadKind : CustomStringConvertible {
    
    public private(set) var name : String
    public private(set) var  detail : String?
    public private(set) var  wraps : Int
    
    init(name: String="",detail: String? = nil,wraps : Int=12) {
        self.name=name
        self.detail=detail
        self.wraps=wraps
    }
    
    
    
    init?(_ row : CSVLoader.Row) {
        guard let n : String = row["name",String.self] else { return nil }
        self.name=n
        self.detail=row["detail",String.self]
        let w : Int? = row["wraps",Int.self]
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

class CSVLoader {
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
    g.rows.forEach { print($0.description) }
    
    let mats = Set(g.rows.compactMap { $0["material",String.self] })
    print(mats.debugDescription)
    
    var thr = [String:[ThreadKind]]()
    mats.forEach { thr[$0]=[] }
    mats.forEach { m in
        let chunk=g.rows.filter { $0["material",String.self]==m }
        thr[m]=chunk.compactMap { ThreadKind($0) }
    }
    
    print(thr.debugDescription)
    //mats.forEach { m in
    //    let chunk = g.filter(on: CSVLoader.MaterialColumn) { $0==m }
    //    thr[m]=chunk.rows.compactMap { ThreadKind($0) }
    //}
    
    //self.grid=g
    self.groups=Array(mats).sorted()
    self.threads=thr //thr.mapValues { rows in rows.compactMap { ThreadKind($0) } }
}

convenience init(path: String) throws {
    try self.init(path: URL(fileURLWithPath: path))
}
}

do {
    let c=try CSVLoader(path: "/Users/julianporter/Workspace/XCode/Lace/lace/threads.csv")
    c.groups.forEach { g in
        print("Group \(g)")
        let t=c.threads[g] ?? []
        t.forEach { print("\($0)") }
    }
}
catch(let e) { print("\(e)") }
