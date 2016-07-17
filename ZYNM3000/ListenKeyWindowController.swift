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

    override func keyUp(_ event: NSEvent) {
        let keycode = Int(event.keyCode)
        switch keycode {
        case 123, 0: // left or a
            NotificationCenter.default.post(name: "left-arrow-key-pressed" as NSNotification.Name, object: nil)
        case 124, 2: // right or d
            NotificationCenter.default.post(name: "right-arrow-key-pressed" as NSNotification.Name, object: nil)
        default:
            break
        }
    }
}
