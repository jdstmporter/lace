import Cocoa

let c = NSColorSpace.availableColorSpaces(with: .rgb)
let n = c.map { "\($0)" }
let col1 = NSColor.blue
let col2 = NSColor.green

let rgb=NSColorSpace.genericRGB
let rgbn = "\(rgb)"
let cs = c.first { "\($0)"==rgbn }
cs?.localizedName

