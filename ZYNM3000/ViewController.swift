//
//  ViewController.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 17/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class ViewController: NSSplitViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.title = "再要你命 3000 - Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)"
        self.view.window?.makeKey()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

