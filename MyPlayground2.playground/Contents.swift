import Foundation

extension Int {
    var f32 : Float { Float(self) }
}

extension Float {
    
    var i32 : Int { Int(self) }
    
    
    var truncated : Float {
        let rnd = (10.0*self).rounded()
        return rnd/10.0
    }
    
    
}

let f : Float = 3.333343325
let ft = f.truncated(nDecimals: 1)
let gt = f.truncated
let s = "\(gt)"

