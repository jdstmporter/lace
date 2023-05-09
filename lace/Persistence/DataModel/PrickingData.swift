//
//  PrickingData.swift
//  lace
//
//  Created by Julian Porter on 08/05/2023.
//

import Foundation
import CoreData

extension PrickingData {
    
    
    func copy(_ obj: PrickingSpecification) {
        self.name = obj.name
        self.width = numericCast(obj.width)
        self.height = numericCast(obj.height)
        self.kind = numericCast(obj.kind.rawValue)
        self.uid = obj.uid
        self.created = obj.created ?? Date.now
    }
    
    func copy() -> PrickingSpecification {
        PrickingSpecification(name: name,width:width,height:height,kind:kind,
                              uid:uid,created:created)
    }
    
}
