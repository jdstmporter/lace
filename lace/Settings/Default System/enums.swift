//
//  enums.swift
//  lace
//
//  Created by Julian Porter on 30/11/2022.
//

import Foundation


public enum DefaultKind : NameableEnumeration {
    case Dimension
    case Colour
    case Font
    case String
    case URL
    case Number
    case Threads
}

public protocol DefaultPart : RawRepresentable, CaseIterable, Hashable, Nameable {
    
}

extension DefaultPart {
    public var str : String { "\(self)" }
}

public enum ViewPart : Int, DefaultPart {
    case Background = 0
    case Grid = 1
    case Pin = 2
    case Line = 3
    
    case Title = 4
    case Metadata = 5
    case Comment = 6
    
    case LastPath = 7
    case DataDirectory = 8
    
    
    public var str : String { "\(self)" }
    
    static let Fonts : [ViewPart] = [.Title,.Metadata,.Comment]
}

public enum FontPart : Int, DefaultPart {
    case Title = 4
    case Metadata = 5
    case Comment = 6
}

public enum PathPart : Int, DefaultPart {
    case DataDirectory = 8
}

public func Key(_ kind : DefaultKind,_ part : any DefaultPart) -> String {
    "\(kind.str)::\(part.str)"
}






