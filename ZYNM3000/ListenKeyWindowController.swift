//
//  ListenKeyWindowController.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 18/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class ListenKeyWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override func keyDown(_ event: NSEvent) {
        
    }

    override func keyUp(_ event: NSEvent) {
        let keycode = Int(event.keyCode)
        switch keycode {
        case 123, 0, 13, 43: // left or a or w or ,
            NotificationCenter.default.post(name: "left-arrow-key-pressed" as NSNotification.Name, object: nil)
        case 124, 2, 1, 49, 36, 47: // right or d or s or space or enter or .
            NotificationCenter.default.post(name: "right-arrow-key-pressed" as NSNotification.Name, object: nil)
        default:
            break
        }
    }
}
