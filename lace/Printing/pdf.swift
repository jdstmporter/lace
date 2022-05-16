//
//  pdf.swift
//  lace
//
//  Created by Julian Porter on 15/05/2022.
//

import Foundation
import ImageIO

enum Keys {
    case DPIWidth
    case DPIHeight
    case TIFFDictionary
    case TIFFXResolution
    case TIFFYResolution
    case JFIFDictionary
    case JFIFXDensity
    case JFIFYDensity
    case JFIFVersion
    case PNGXResolution
    case PNGYResolution
    case PNGDictionary
    
    static let values : [Keys:CFString] = [
        .DPIWidth : kCGImagePropertyDPIWidth,
        .DPIHeight : kCGImagePropertyDPIHeight,
        .TIFFDictionary : kCGImagePropertyTIFFDictionary,
        .TIFFXResolution : kCGImagePropertyTIFFXResolution,
        .TIFFYResolution : kCGImagePropertyTIFFYResolution,
        .JFIFDictionary : kCGImagePropertyJFIFDictionary,
        .JFIFVersion : kCGImagePropertyJFIFVersion,
        .JFIFXDensity : kCGImagePropertyJFIFXDensity,
        .JFIFVersion : kCGImagePropertyJFIFYDensity,
        .PNGXResolution : kCGImagePropertyPNGXPixelsPerMeter,
        .PNGYResolution : kCGImagePropertyPNGYPixelsPerMeter,
        .PNGDictionary : kCGImagePropertyPNGDictionary
    ]
    
    var cf : CFString { Keys.values[self]! }
    var str : String { self.cf as String }
}

typealias DataDict = [String:Any]


func asDataDict(_ dict : Any?) -> DataDict { (dict as? DataDict) ?? DataDict() }


struct Metadata {
    var metadata : DataDict = [:]
    
    init(_ dict : CFDictionary) {
        self.metadata = asDataDict(dict)
    }
    init (_ src : CGImageSource) {
        let d = CGImageSourceCopyPropertiesAtIndex(src,0, nil)
        self.metadata=asDataDict(d)
    }
    
    var asCFDict : CFDictionary? { metadata as CFDictionary? }
    
    var exifDictionary : DataDict {
        get { asDataDict(metadata[Keys.TIFFDictionary.str]) }
        set { metadata[Keys.TIFFDictionary.str] = newValue }
    }
    var jfifDictionary : DataDict {
        get { asDataDict(metadata[Keys.JFIFDictionary.str]) }
        set { metadata[Keys.JFIFDictionary.str] = newValue }
    }
    subscript(_ key : CFString) -> Any? {
        get { metadata[key as String] }
        set { metadata[key as String] = newValue }
    }
}


