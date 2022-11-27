//
//  Log.swift
//  lace
//
//  Created by Julian Porter on 05/05/2022.
//

import Foundation
import OSLog



public protocol Loggable {
    var str : String { get }
}
public protocol BaseError : Error, Loggable {}

extension BaseError {
    public var str : String { "\(self)" }
}
extension String : BaseError {}



public class SysLog {
    private var log : Logger
    private var isDebug : Bool
    
    public init(_ subsystem : String,category : String = "System Log",debug: Bool = false) {
        log=Logger(subsystem: subsystem, category: category)
        isDebug = debug
    }
    public init() {
        log=Logger() //OSLog.default
        isDebug=false
    }
    
    public func debugOn() { isDebug=true }
    public func debugOff() { isDebug=false }
    
    public func debug(_ message : BaseError) {
        if isDebug {
            self.log.debug("\(message.str)")
        }
    }
    public func info(_ message : BaseError)  { self.log.info("\(message.str)") }
    public func announce(_ message : BaseError) { self.log.notice("\(message.str)") }
    public func error(_ message : BaseError) { self.log.error("\(message.str)") }
    public func fault(_ message : BaseError) { self.log.fault("\(message.str)") }
    
    public func say(_ message : CustomStringConvertible) { self.log.log("\(message.description)") }
}

public let syslog = SysLog("lace",debug: true)


