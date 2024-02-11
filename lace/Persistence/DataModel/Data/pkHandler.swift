//
//  pkHandler.swift
//  lace
//
//  Created by Julian Porter on 28/08/2023.
//

import Foundation
import CoreData

extension DataHandler {
    
    func nextPK<T>(_ typename: T.Type) -> Int32 where T : Root {
        do {
            let all : [T] = try self.getAll()
            guard let ma = (all.map { $0.pk }).max() else { return 0 }
            return ma+1
        }
        catch { return 0 }
    }
}
