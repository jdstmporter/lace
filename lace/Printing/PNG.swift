//
//  pdf.swift
//  lace
//
//  Created by Julian Porter on 15/05/2022.
//

import Foundation
import AppKit
import ImageIO
import UniformTypeIdentifiers



extension Int : Defaultable { static var zero: Int { 0 } }
extension Float : Defaultable { static var zero: Float { 0 } }
extension Double : Defaultable { static var zero: Double { 0 } }
extension Bool : Defaultable { static var zero: Bool { false } }
extension NSSize : Defaultable { static var zero: NSSize { NSSize() } }
extension String : Defaultable { static var zero: String { "" } } 



typealias DataDict = [String:Any]
 
extension CGColorSpaceModel {
    
    var name : String {
        switch self {
        case .monochrome:
            return "monochrome"
        case .rgb:
            return "rgb"
        case .cmyk:
            return "cmyk"
        case .lab:
            return "lab"
        case .deviceN:
            return "deviceN"
        case .indexed:
            return "indexed"
        case .pattern:
            return "pattern"
        case .XYZ:
            return "xyz"
        default:
            return "unknown"
        }
    }
}

class PNG {
    static let MetadataKey = kCGImagePropertyPNGDictionary as String
    static let ResX = kCGImagePropertyPNGXPixelsPerMeter as String
    static let ResY = kCGImagePropertyPNGYPixelsPerMeter as String
    static let Interlace = kCGImagePropertyPNGInterlaceType as String
    static let PixelWidth = kCGImagePropertyPixelWidth as String
    static let PixelHeight = kCGImagePropertyPixelHeight as String
    static let DPIWidth = kCGImagePropertyDPIWidth as String
    static let DPIHeight = kCGImagePropertyDPIHeight as String
    static let ColourModel = kCGImagePropertyColorModel as String
    static let Depth = kCGImagePropertyDepth as String
    static let HasAlpha = kCGImagePropertyHasAlpha as String
    
    static let InchesPerMetre : Double = 39.3701
    static let alphas : [CGImageAlphaInfo] = [.first,.last,.alphaOnly,.premultipliedLast,.premultipliedLast]
    
    public private(set) var properties : DataDict = [:]
    public private(set) var dict : DataDict = [:]
        
    public init() {
        self.properties=[:]
        self.dict=[:]
    }
    
    init(size: NSSize,colourModel: String,depth: Int,alpha: Bool,dpi : NSSize) {
        let dpm=dpi*PNG.InchesPerMetre
        self.dict[PNG.PixelWidth]=size.widthI
        self.dict[PNG.PixelHeight]=size.heightI
        self.dict[PNG.Interlace] = 0
        self.dict[PNG.ResX]=dpm.widthI
        self.dict[PNG.ResY]=dpm.heightI
      
        self.properties[PNG.MetadataKey] = self.dict
        
        self.properties[PNG.DPIWidth]=dpi.widthI
        self.properties[PNG.DPIHeight]=dpi.heightI
        self.properties[PNG.ColourModel] = colourModel
        self.properties[PNG.Depth] = depth
        self.properties[PNG.HasAlpha] = alpha
    }
    
    
    convenience init(image: CGImage,dpi : NSSize) {
        let sz=NSSize(width:image.width,height:image.height)
        let al=PNG.alphas.contains(image.alphaInfo)
        let mo=image.colorSpace?.model.name ?? "unknown"
        self.init(size: sz,colourModel: mo,
                  depth: image.bitsPerPixel,alpha: al,dpi: dpi)
    }
    
    var propertiesCF : CFDictionary { self.properties as CFDictionary }
}

class RenderPNG {
    
    var image : CGImage
    var properties : PNG
    
    static let utype = UTType.png.identifier
    
    init(image: CGImage,dpi: NSSize) {
        self.image=image
        self.properties=PNG(image: image,dpi: dpi)
    }
    
    func renderToLocation(path : URL) throws {
        guard let dest = CGImageDestinationCreateWithURL(path as CFURL,RenderPNG.utype as CFString, 1, self.properties.propertiesCF) else { throw FileError.CannotCreateDestination }
        CGImageDestinationAddImage(dest, image, self.properties.propertiesCF)
        CGImageDestinationFinalize(dest)
    }
    
    func renderToData() throws -> Data {
        guard let array=CFDataCreateMutable(kCFAllocatorDefault,0),
              let dest = CGImageDestinationCreateWithData(array, RenderPNG.utype as CFString, 1, nil) else { throw FileError.CannotCreateDestination }
        CGImageDestinationAddImage(dest, image, self.properties.propertiesCF)
        CGImageDestinationFinalize(dest)
        return array as Data
    }
    
    

}
