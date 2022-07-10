//
//  Errors.swift
//  lace
//
//  Created by Julian Porter on 29/05/2022.
//

import Foundation
import SQLite3



enum PrinterError : BaseError {
    case GeneralError(OSStatus)
    case PointerError
    case CannotGetName
    case CannotGetID
    case CannotGetURL
    case DataError(String)
    
    static func wrap(_ e : OSStatus) throws {
        guard e==0 else { throw PrinterError.GeneralError(e) }
    }
}

enum LaceError : BaseError {
    case CannotGetImageData
    case CannotMakeImage
    case BadLaceStyleName
    case StyleWindingMismatch
    case CannotFindThreadsCSV
}
enum SQLiteError : BaseError {
    case GeneralError(Int32)
    case CannotOpenDatabase
    case CannotPrepareQueryStatement
    case UnknownDataType(Int32)
    
    static func wrap(_ code : Int32) throws {
        if code != SQLITE_OK { throw SQLiteError.GeneralError(code) }
    }
}

enum DefaultError : BaseError {
    case CannotGetKey(String)
    case BadColourFormat
    case BadFontFormat
    case CannotGetDefaults
    case CannotGetURL
    case DocumentHasNoRoot
    case CannotFindDefault
}

enum FileError : BaseError {
    case CannotFindBundleIdentifier
    case CannotCreateDataDirectory
    case CannotPickLoadFile
    case CannotPickSaveFile
    case CannotCreateDestination
}

