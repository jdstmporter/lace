import Cocoa
import OSLog

extension Float {
    func truncated(nDecimals: Int = 1) -> Float {
        let factor : Float = (0..<nDecimals).reduce(1.0) { (res,_) in 10.0*res }
        let rnd = (self*factor).rounded()
        return Float(rnd)/factor
    }
}

let x=Float(100.0/36.0)
let y=x.truncated(nDecimals: 1)


