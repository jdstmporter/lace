import Cocoa
import CoreGraphics

let r=NSColor.red
let w=NSColor.white
let b=NSColor.black

let rc=r.cgColor
let wc=w.cgColor
let bc=b.cgColor

let rcs=rc.colorSpace
let wcs=wc.colorSpace
let bcs=bc.colorSpace

let cs=CGColorSpaceCreateDeviceRGB()
let rcc=rc.converted(to: cs, intent: .defaultIntent, options: nil)
let wcc=wc.converted(to: cs, intent: .defaultIntent, options: nil)
let bcc=bc.converted(to: cs, intent: .defaultIntent, options: nil)

let rgb = NSColorSpace.deviceRGB
let cgrgb = rgb.cgColorSpace

