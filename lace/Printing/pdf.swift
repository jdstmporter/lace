//
//  pdf.swift
//  lace
//
//  Created by Julian Porter on 15/05/2022.
//

import Foundation
import PDFKit

class Delegate : NSObject, PDFDocumentDelegate {
    
    func classForPage() -> AnyClass { ImagePage.self }
}

class ImagePage : PDFPage {
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        
        context.saveGState()
        
        context.draw(<#T##image: CGImage##CGImage#>, in: <#T##CGRect#>)
        
        context.restoreGState()
    }
    
}
