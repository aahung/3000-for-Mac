//
//  SpeakerImageButton.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 18/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class SpeakerImageButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let focusTrackingAreaOptions =  NSTrackingAreaOptions(rawValue: NSTrackingAreaOptions.activeInActiveApp.rawValue |
            NSTrackingAreaOptions.mouseEnteredAndExited.rawValue |
            NSTrackingAreaOptions.assumeInside.rawValue |
            NSTrackingAreaOptions.inVisibleRect.rawValue)
        
        let focusTrackingArea = NSTrackingArea(rect: NSZeroRect, options: focusTrackingAreaOptions, owner: self, userInfo: nil)
        self.addTrackingArea(focusTrackingArea)
    }
    
    override func mouseExited(_ event: NSEvent) {
        super.mouseEntered(event)
        self.image = #imageLiteral(resourceName: "Speaker")
    }
    
    override func mouseEntered(_ event: NSEvent) {
        super.mouseEntered(event)
        self.image = #imageLiteral(resourceName: "Speaker Filled")
    }
}
