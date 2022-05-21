//
//  ImageTest.swift
//  lace
//
//  Created by Julian Porter on 21/05/2022.
//

import Foundation
import AppKit
import UniformTypeIdentifiers
import ImageIO

func sourceTypes() -> [String] {
    let a = CGImageSourceCopyTypeIdentifiers()
    return a as! Array<String>
}
func destinationTypes() -> [String] {
    let a = CGImageDestinationCopyTypeIdentifiers()
    return a as! Array<String>
}

enum KError : Error {
    case Src
    case Img
    case Prop
    case Ty
    case Dst
}

let CGImagePropertyDPIWidth = kCGImagePropertyDPIWidth as String
let CGImagePropertyDPIHeight = kCGImagePropertyDPIHeight as String
let CGImagePropertyTIFFDictionary = kCGImagePropertyTIFFDictionary as String
let CGImagePropertyTIFFXResolution = kCGImagePropertyTIFFXResolution as String
let CGImagePropertyTIFFYResolution = kCGImagePropertyTIFFYResolution as String

let CGImagePropertyJFIFDictionary = kCGImagePropertyJFIFDictionary as String
let CGImagePropertyJFIFXDensity = kCGImagePropertyJFIFXDensity as String
let CGImagePropertyJFIFYDensity = kCGImagePropertyJFIFYDensity as String
let CGImagePropertyJFIFVersion = kCGImagePropertyJFIFVersion as String

func loadSaveScale(input p: String,output q: String) throws {

        let path = NSURL(fileURLWithPath: p)
        
        let info = [
            kCGImageSourceShouldCache : true,
            kCGImageSourceShouldAllowFloat : true
        ]
        guard let src = CGImageSourceCreateWithURL(path as CFURL, info as CFDictionary) else { throw KError.Src }
        guard let image = CGImageSourceCreateImageAtIndex(src, 0, nil) else { throw KError.Img }
        guard let ky = CGImageSourceCopyPropertiesAtIndex(src,0, nil) else { throw KError.Prop }
        
        guard let ty = CGImageSourceGetType(src) else { throw KError.Ty }
        let dpi : Int = 300
        var keys = ky as? [String:Any] ?? [String:Any]()
        keys[CGImagePropertyDPIWidth] = dpi
        keys[CGImagePropertyDPIHeight] = dpi
        
        var exifDictionary = keys[CGImagePropertyTIFFDictionary] as? [String:Any] ?? [String:Any]()
        exifDictionary[CGImagePropertyTIFFXResolution] = dpi
        exifDictionary[CGImagePropertyTIFFYResolution] = dpi
        keys[CGImagePropertyTIFFDictionary] = exifDictionary
        
        var jfifDictionary = keys[CGImagePropertyJFIFDictionary] as? [String:Any] ?? [String:Any]()
        jfifDictionary[CGImagePropertyJFIFXDensity] = dpi
        jfifDictionary[CGImagePropertyJFIFYDensity] = dpi
        jfifDictionary[CGImagePropertyJFIFVersion ] = 1
        keys[CGImagePropertyJFIFDictionary] = jfifDictionary
        
        
        let path2 = NSURL(fileURLWithPath: q)
        guard let dest = CGImageDestinationCreateWithURL(path2 as CFURL, ty, 1, keys as CFDictionary?) else { throw KError.Dst }
        CGImageDestinationAddImage(dest, image, keys as CFDictionary?)
        CGImageDestinationFinalize(dest)

}

/*
 Image property dictionaries
 EXIF -> JPG and TIF and some PNGs
 TIFF -> Same as EXIF
 JFIF -> some JPG
 PMG  -> PNG
 
 For PNG, minimum is
 DPIWidth
 DPIHeight
 PixelWidth
 PixelHeight
 ColorModel = RGB
 HasAlpha = 0 or 1
 Depth
 PNG {
    InterlaceType = 0
    XPixelsPerMetre
    YPixelsPerMetry
 }
 
 */



func listProps(path p: String) throws {
    let path = NSURL(fileURLWithPath: p)
    
    let info = [
        kCGImageSourceShouldCache : true,
        kCGImageSourceShouldAllowFloat : true
    ]
    guard let src = CGImageSourceCreateWithURL(path as CFURL, info as CFDictionary) else { throw KError.Src }
    //guard let image = CGImageSourceCreateImageAtIndex(src, 0, nil) else { throw KError.Img }
    guard let ky = CGImageSourceCopyPropertiesAtIndex(src,0, nil) else { throw KError.Prop }
    
    guard let ty = CGImageSourceGetType(src) else { throw KError.Ty }
    let keys = ky as? [String:Any] ?? [String:Any]()
    
    print(p)
    print("Type is \(ty)")
    keys.forEach { print("\($0.key) == \($0.value)")}
}


func printActions() {
    do {
        let inp = "/Users/julianporter/Pictures/Excel/Ropponmatsu_II_244.jpg"
        let out = "/Users/julianporter/Pictures/Excel/Ropponmatsu_II_244_300.jpg"
        try listProps(path: inp)
        try loadSaveScale(input: inp, output: out)
        try listProps(path: out)
    }
    catch(let e) { print(e) }
}

    
