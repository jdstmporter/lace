import Cocoa

let fm = NSFontManager.shared
let all = fm.availableFonts
let sp = all.filter { $0.contains(" ")}
all.forEach { print($0) }
print("\(all.count) > \(sp.count)")

let f = fm.font(withFamily: "Menlo", traits: .fixedPitchFontMask, weight: 8, size: 12)

f?.familyName
f?.displayName
f?.pointSize
fm.weight(of: f!)
let m = fm.traits(of: f!)
m.rawValue

NSFontDescriptor.SymbolicTraits.monoSpace.rawValue
f?.fontName

let g=NSFont(name: f!.fontName, size: 12)!
let d=print(g.description)



