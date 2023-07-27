//
//  dataTypes.swift
//  lace
//
//  Created by Julian Porter on 26/07/2023.
//

import Foundation
import CoreData

enum DataError : Error {
    case PrickingHasNilIdentity
    case PrickingHasNoManagedObjectContext
    case BadTypeNameForDataLayer
}


