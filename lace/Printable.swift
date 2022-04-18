//
//  Printable.swift
//  lace
//
//  Created by Julian Porter on 03/04/2022.
//

import Foundation
import AppKit

enum LaceError : Error {
    case CannotGetImageData
    case CannotMakeImage
}

func numericCast<T>(_ f : CGFloat) -> T
where T : BinaryInteger
{ T(f) }

class Image {
    
    var bitmap : NSBitmapImageRep
    var grid : Grid
    var data : [UInt8]
    var size : NSSize
    var width: Int { Int(self.size.width) }
    var height : Int { Int(self.size.height) }
    
    var MaxWidth : Double = 50.0
    var MaxHeight : Double = 50.0
    
    
    init?(grid : Grid,width: Int,height: Int) {
        self.size=NSSize(width: width, height: height)
        self.grid=grid
        self.data=Array<UInt8>(repeating: 255, count: width*height)
        
        let p = self.data.withUnsafeMutableBufferPointer { ptr in ptr.baseAddress }
        var pl=[p]
        guard let bitmap = NSBitmapImageRep.init(bitmapDataPlanes: &pl,
                                                 pixelsWide: width, pixelsHigh: height,
                                                 bitsPerSample: 8, samplesPerPixel: 1,
                                                 hasAlpha: false, isPlanar: false,
                                                 colorSpaceName: .calibratedWhite,
                                                 bitmapFormat: NSBitmapImageRep.Format(rawValue: 0),
                                                 bytesPerRow: width, bitsPerPixel: 8)
                            else { return nil }
        self.bitmap=bitmap
        
    }
    
    func draw() {
        let xs = size.width/(self.MaxWidth+2.0)
        let ys = size.height/(self.MaxHeight+2.0)
        //spacing = Swift.max(xs,ys)
        grid.scale = Swift.max(xs,ys)
        
        var pix=[0]
        grid.forEachY { y in
            self.bitmap.setPixel(&pix, atX: 0, y: y);
            self.bitmap.setPixel(&pix, atX: numericCast(size.width)-1, y: y);
        }
        grid.forEachX { x in
            self.bitmap.setPixel(&pix, atX: x, y: 0);
            self.bitmap.setPixel(&pix, atX: x, y: numericCast(size.height)-1);
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
                            let offset=px+self.width*py
                            if offset>=0 && offset<width*height {
                                var pix = [0]
                                self.bitmap.setPixel(&pix, atX: px, y: py) }
                        }
                    }
                }
   
            }
        }
    
    }
    
    func save() throws {
        guard let file = self.bitmap.representation(using: .png, properties: [:]) else { throw LaceError.CannotGetImageData }
        try file.write(to: URL(fileURLWithPath: "/Users/julianporter/fred.png"))
    }
    
    
}
