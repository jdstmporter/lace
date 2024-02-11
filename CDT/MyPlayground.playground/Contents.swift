import Cocoa

func fromData<T>(_ data : Data) -> T  {
    return data.withUnsafeBytes { raw in
        return raw.load(fromByteOffset: 0, as: T.self)
    }
}
func toData<T>(_ value : T) -> Data   {
    var s=value
    return withUnsafePointer(to: &s) { p in
        var raw = UnsafeRawPointer(p)
        return Data(bytes: raw, count: MemoryLayout<T>.size)
    }
}
func toData<T>(_ value : [T]) -> Data {
    let n=value.count
    var s=value
    return withUnsafePointer(to: &s) { p in
        var raw = UnsafeRawPointer(p)
        return Data(bytes: raw, count: MemoryLayout<T>.size*n)
    }
}



struct P : CustomStringConvertible {
    let x : Int32
    let y : Int32
    
    var description: String { "\(x), \(y)"}
}




var x : [Int32] = [1,2,3,4]
let d=toData(x)
let v : [Int32] = fromData(d)

var p = P(x:47,y: -93)
let e=toData(p)
let pp : P = fromData(e)

let bb = false
let dd=toData(bb)
let vv : Bool = fromData(dd)

let s = "1233457"
let aa = Array(s)
let sd = toData(Array(s))
let sa : [String.Element] = fromData(sd)
let ss = String(sa)

let os = toData(s)
let so :String = fromData(os)
