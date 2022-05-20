//
//  PrintableCG.swift
//  lace
//
//  Created by Julian Porter on 20/05/2022.
//

import Foundation
import CoreGraphics

class ImageCG {
    
    var bitmap : CGImage
    var grid : Grid
    var data : Data
    var provider : CGDataProvider
    var size : NSSize
    var width: Int { Int(self.size.width) }
    var height : Int { Int(self.size.height) }
    
    var MaxWidth : Double = 50.0
    var MaxHeight : Double = 50.0
    
    
    init?(grid : Grid,width: Int,height: Int) {
        self.size=NSSize(width: width, height: height)
        self.grid=grid
        self.data=Data(repeating: 255, count: width*height)
        
        
        
        let colourSpace = CGColorSpace(name: CGColorSpace.linearGray)!
        
        provider = CGDataProvider(data: data as CFData)!
        guard let bitmap = CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: width, space: colourSpace, bitmapInfo: [], provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else { return nil }
        self.bitmap=bitmap
        
    }
    
    // draw on the data file in the provider
    // then construct the CGImage
    // then pass it over to the renderer
    
    func save() throws {
        guard let file = self.bitmap.representation(using: .png, properties: [:]) else { throw LaceError.CannotGetImageData }
        try file.write(to: URL(fileURLWithPath: "/Users/julianporter/fred.png"))
    }
    
    func setPixel(_ pix : inout [Int], atX: Int, y: Int) {
        let pos=Int(self.size.width)*y+atX
        self.data[pos]=numericCast(pix[0])
    }
    
    
    func draw() {
        let xs = size.width/(self.MaxWidth+2.0)
        let ys = size.height/(self.MaxHeight+2.0)
        //spacing = Swift.max(xs,ys)
        grid.scale = Swift.max(xs,ys)
        
        var pix=[0]
        grid.forEachY { y in
            self.setPixel(&pix, atX: 0, y: y);
            self.setPixel(&pix, atX: numericCast(size.width)-1, y: y);
        }
        grid.forEachX { x in
            self.setPixel(&pix, atX: x, y: 0);
            self.setPixel(&pix, atX: x, y: numericCast(size.height)-1);
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
                                self.setPixel(&pix, atX: px, y: py) }
                        }
                    }
                }
   
            }
        }
    
    }
    
}
