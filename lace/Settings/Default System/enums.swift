//
//  enums.swift
//  lace
//
//  Created by Julian Porter on 30/11/2022.
//

import Foundation

public enum ResolutionMode : Int, NameableEnumeration, RawConstructibleEnumeration {
    case Printer = 0
    case List = 1
    
    public static var zero : ResolutionMode { .List }
}

public enum ThreadMode : Int, NameableEnumeration, RawConstructibleEnumeration {
    case Library = 0
    case Custom = 1
    
    public static var zero: ThreadMode { .Library }
    

}
public enum SpaceMode : Int, NameableEnumeration, RawConstructibleEnumeration {
    case Kind = 0
    case CustomKind = 1
    case CustomSpace = 2
    
    public static var zero: SpaceMode { .Kind }
}

public enum DefaultKind : NameableEnumeration {
    case Dimension
    case Colour
    case Font
    case String
    case URL
    case Number
    case Threads
    
    public static var zero : DefaultKind { .Dimension }
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

public enum ThreadPart : Int, DefaultPart {
    
    case printer = 0
    case printerOrList = 1
    case resolution = 2
    case threadMode = 3
    case material = 4
    case thread = 5
    case threading = 6
    case spaceMode = 7
    case laceKind = 8
    case laceKindWinding = 9
    case pinSpacing = 10
    
    
}

public func Key(_ kind : DefaultKind,_ part : any DefaultPart) -> String {
    "\(kind.str)::\(part.str)"
}






