import Cocoa
import OSLog

let cased : [OSLogType] = [ .debug, .info,.error, .default ]
let vals = cased.map { $0.rawValue }
vals


