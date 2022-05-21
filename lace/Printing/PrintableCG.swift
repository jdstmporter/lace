//
//  PrintableCG.swift
//  lace
//
//  Created by Julian Porter on 20/05/2022.
//

import Foundation
import CoreGraphics
import AppKit

enum LaceError : BaseError {
    case CannotGetImageData
    case CannotMakeImage
}

func numericCast<T>(_ f : CGFloat) -> T
where T : BinaryInteger
{ T(f) }

extension NSSize {
    var widthI : Int { numericCast(width) }
    var heightI : Int { numericCast(height) }
    var area : Int { widthI*heightI }
    
    init(side: Int) { self.init(width: side,height: side) }
    
    static func * (_ s : NSSize,_ f : Double) -> NSSize { NSSize(width: s.width*f,height: s.height*f) }
    static func * (_ s : NSSize,_ i : Int) -> NSSize { s*Double(i) }
}



class ImageCG {
    
    var bitmap : NSBitmapImageRep
    var grid : Grid
    var data : [UInt8]
    var size : NSSize
    var dpi : NSSize
    var width: Int { self.size.widthI }
    var height : Int { self.size.heightI }
    var N : Int
    var MaxWidth : Double = 50.0
    var MaxHeight : Double = 50.0
    
    
    init?(grid : Grid,width w: Int,height h: Int,spacing: Double,dpi: Int = 300) {
        let size=NSSize(width: w*dpi,height: h*dpi)*spacing
        self.size=size
        self.grid=grid
        self.dpi=NSSize(side: dpi)
        self.data=Array<UInt8>(repeating: 255, count: size.area)
        self.N=self.data.count
        
        let p = self.data.withUnsafeMutableBufferPointer { ptr in ptr.baseAddress }
        var pl=[p]
        guard let bitmap = NSBitmapImageRep.init(bitmapDataPlanes: &pl,
                                                 pixelsWide: size.widthI, pixelsHigh: size.heightI,
                                                 bitsPerSample: 8, samplesPerPixel: 1,
                                                 hasAlpha: false, isPlanar: false,
                                                 colorSpaceName: .calibratedWhite,
                                                 bitmapFormat: NSBitmapImageRep.Format(rawValue: 0),
                                                 bytesPerRow: size.widthI, bitsPerPixel: 8)
        else { return nil }
        self.bitmap=bitmap
        
    }
    
    // draw on the data file in the provider
    // then construct the CGImage
    // then pass it over to the renderer
    
    func save() throws {
        guard let cg = self.bitmap.cgImage else { throw LaceError.CannotGetImageData }
        let renderer = RenderPNG(image: cg, dpi: self.dpi)
        try renderer.renderToFile(path: URL(fileURLWithPath: "/Users/julianporter/fred.png"))
    }
    
    func asData() throws -> Data {
        guard let cg = self.bitmap.cgImage else { throw LaceError.CannotGetImageData }
        let renderer = RenderPNG(image: cg, dpi: self.dpi)
        return try renderer.renderAsData()
        
    }
    
    private func setPixel(_ pix : Int, atX: Int, y: Int) {
        var v=[pix]
        self.bitmap.setPixel(&v, atX: atX, y: y)
    }
    
    
    func draw() {
        let xs = size.width/(self.MaxWidth+2.0)
        let ys = size.height/(self.MaxHeight+2.0)
        //spacing = Swift.max(xs,ys)
        grid.scale = Swift.max(xs,ys)
        
        //var pix=[0]
        grid.forEachY { y in
            self.setPixel(0, atX: 0, y: y);
            self.setPixel(0, atX: numericCast(size.width)-1, y: y);
        }
        grid.forEachX { x in
            self.setPixel(0, atX: x, y: 0);
            self.setPixel(0, atX: x, y: numericCast(size.height)-1);
        }
        
        grid.forEachY { y in
            //let yy=Double(y)
            //let yf=Double(y%2)/2.0
            grid.forEachX { x in
                if self.grid[x,y] {
                    let p = grid.pos(x, y)
                    (-5...5).forEach { xx in
                        (-5...5).forEach { yy in
                            let px=numericCast(p.x)+xx
                            let py=numericCast(p.y)+yy
                            self.setPixel(0, atX: px, y: py)
                            //let offset=px+self.width*py
                            //if offset>=0 && offset<width*height {
                            //    self.setPixel(0, atX: px, y: py) }
                        }
                    }
                }
   
            }
        }
    
    }
    
}
