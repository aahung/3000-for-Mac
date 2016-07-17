//
//  NoExtraGridOutlineView.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 18/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class NoExtraGridOutlineView: NSOutlineView {
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func drawGrid(inClipRect clipRect: NSRect) {
        let lastRowRect = self.rect(ofRow: self.numberOfRows - 1)
        let lastColumnRect = self.rect(ofColumn: self.numberOfColumns - 1)
        let myClipRect = NSMakeRect(0, 0, NSMaxX(lastColumnRect), NSMaxY(lastRowRect))
        super.drawGrid(inClipRect: myClipRect)
    }
}
