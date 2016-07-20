//
//  XHSearchViewController.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 20/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class XHSearchViewController: NSViewController, NSComboBoxDelegate, NSComboBoxDataSource, NSControlTextEditingDelegate {

    @IBOutlet weak var searchComboBox: NSComboBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchComboBox.delegate = self
        searchComboBox.dataSource = self
        searchComboBox.usesDataSource = true
    }
    
    var words: [Word]?
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let words = words {
            return words.count
        }
        return 0
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> AnyObject? {
        if words?.count > index {
            return words?[index].spelling
        }
        return nil
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var i = 0
        for word in self.words! {
            if word.spelling == string {
                return i
            }
            i += 1
        }
        return -1
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        searchString(string: self.searchComboBox.stringValue)
    }
    
    func searchString(string: String) {
        Words3000.shared.words(like: string) { (words) in
            self.words = words
            OperationQueue.main.addOperation {
                self.searchComboBox.reloadData()
            }
        }
    }
    
    @IBAction func chooseWord(_ sender: AnyObject) {
        if self.searchComboBox.indexOfSelectedItem == -1 {
            return
        }
        let selectedWord = self.words![self.searchComboBox.indexOfSelectedItem]
        print("searchDidSelect: \([selectedWord.list, selectedWord.unit, selectedWord.orderInUnit])")
        OperationQueue.main.addOperation {
            NotificationCenter.default.post(Notification(name: "select-word-in-hierarchy" as Notification.Name, object: nil, userInfo: ["word": selectedWord]))
            self.dismiss(self)
        }
    }
}
