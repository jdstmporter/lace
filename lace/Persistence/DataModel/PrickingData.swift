//
//  PrickingData.swift
//  lace
//
//  Created by Julian Porter on 08/05/2023.
//

import Foundation
import CoreData

extension BinaryInteger {
    
    subscript(_ idx : Int) -> Bool {
        get { (self >> idx) & 1 == 1 }
        set(b) {
            self = b ? self | (1<<idx) : self & ~(1<<idx)
        }
    }
}

struct BitArray {
    
    var words : [UInt8]
    var bools : [Bool]
    
    init(words : [UInt8], count : Int) {
        
        let nBool=Swift.min(count,words.count*8)
        var bools=Array<Bool>(repeating: false, count: nBool)
        
        (0..<nBool).forEach { nb in
            let word = nb/8
            let offset = nb%8
            bools[nb]=words[word][offset]
        }
        
        self.words=words
        self.bools=bools
    }
    
    init(bools : [Bool]) {
        let n=bools.count
        let nWords = (n+7)>>3
        var words=Array<UInt8>(repeating: 0, count: nWords)
        
        (0..<n).forEach { nb in
            let word = nb/8
            let offset = nb%8
            words[word][offset]=bools[nb]
        }
        
        self.words=words
        self.bools=bools
    }
    
    init(data: Data, count : Int) {
        var bytes = Array<UInt8>(repeating: 0, count: data.count)
        bytes.withUnsafeMutableBufferPointer { ptr in
            guard var base = ptr.baseAddress else { return }
            data.copyBytes(to: base, count: data.count)
        }
        self.init(words: bytes, count: count)
    }
    
    var data : Data { Data(words) }
    
}

extension PrickingData {
    
    var w : Int {
        get { numericCast(self.width) }
        set(i) { self.width=numericCast(i) }
    }
    var h : Int {
        get { numericCast(self.height) }
        set(i) { self.height=numericCast(i) }
    }
    var size : Int { w*h }
    
    func initialiseGrid() {
        self.gridBytes = Data()
    }
    
    
    var grid : [Bool] {
        get { BitArray(data: self.gridBytes ?? Data(),count: self.size).bools }
        set(a) { self.gridBytes=BitArray(bools: a).data }
    }
    
    
    
   
    
}

