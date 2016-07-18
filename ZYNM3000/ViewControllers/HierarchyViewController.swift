//
//  HierarchyViewController.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 18/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class HierarchyViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    class List {
        var id: Int
        var units: [Unit]
        init(id: Int, unitIds: [Int]) {
            self.id = id
            self.units = [Unit]()
            for unitId in unitIds {
                units.append(Unit(list: self, id: unitId))
            }
        }
    }
    
    class Unit {
        weak var list: List?
        var id: Int
        var words: [Word]!
        init(list: List, id: Int) {
            self.list = list
            self.id = id
        }
    }
    
    var lists = [List]()

    weak var containerViewController: ViewController!
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWords()
        
        self.outlineView.dataSource = self
        self.outlineView.delegate = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(wordDisplayed), name: "word-displayed" as NSNotification.Name, object: nil)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self, name: "word-displayed" as NSNotification.Name, object: nil)
        super.viewDidDisappear()
    }
    
    func initWords() {
        for listId in containerViewController.words3000.lists() {
            let list = List(id: listId, unitIds: containerViewController.words3000.units(list: listId))
            lists.append(list)
            for unit in list.units {
                unit.words = containerViewController.words3000.words(list: listId, unit: unit.id)
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) != 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil {
            return lists.count
        } else {
            if item is Word {
                return 0
            } else if item is Unit {
                return (item as! Unit).words.count
            } else if item is List {
                return (item as! List).units.count
            } else {
                fatalError()
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return lists[index]
        } else {
            if item is Unit {
                return (item as! Unit).words[index]
            } else if item is List {
                return (item as! List).units[index]
            } else {
                fatalError()
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        if tableColumn?.identifier == "outline-text-column" {
            let cell = outlineView.make(withIdentifier: "outline-text-cell", owner: self) as? NSTableCellView
            
            if item is Word {
                cell?.textField?.stringValue = "\((item as! Word).spelling) - \((item as! Word).chineseMeaning)"
            } else if item is Unit {
                cell?.textField?.stringValue = "Unit \((item as! Unit).id)"
            } else if item is List {
                cell?.textField?.stringValue = "List \((item as! List).id)"
            } else {
                fatalError()
            }
            
            return cell
        } else if tableColumn?.identifier == "outline-button-column" {
            let cell = outlineView.make(withIdentifier: "outline-button-cell", owner: self) as? OutlineButtonView
            
            var id = 0
            if item is Word {
                id = (item as! Word).list * 10000 + (item as! Word).unit * 100 + (item as! Word).orderInUnit
            } else if item is Unit {
                id = (item as! Unit).list!.id * 10000 + (item as! Unit).id * 100
            } else if item is List {
                id = (item as! List).id * 10000
            }
            
            cell?.goButton.tag = id
            cell?.goButton.target = self
            cell?.goButton.action = #selector(goButtonClicked(sender:))
            
            return cell
        }
        
        return nil
    }
    
    func goButtonClicked(sender: NSButton) {
        let tag = sender.tag
        let list = tag / 10000
        var unit = tag % 10000 / 100
        var orderInUnit = tag % 100
        if unit == 0 {
            unit = 1
        }
        if orderInUnit == 0 {
            orderInUnit = 1
        }
        if let word = containerViewController.words3000.word(list: list, unit: unit, orderInUnit: orderInUnit) {
            containerViewController.wordDetailViewController.displayWord(word: word)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: AnyObject) -> CGFloat {
        return 30.0
    }
    
    func wordDisplayed(notification: Notification) {
        let userInfo = notification.userInfo!
        let list = userInfo["list"] as! Int
        let unit = userInfo["unit"] as! Int
        let orderInUnit = userInfo["orderInUnit"] as! Int
        let theList = self.lists[list - 1]
        let theUnit = theList.units[unit - 1]
        let theWord = theUnit.words[orderInUnit - 1]
        OperationQueue.main.addOperation {
            self.outlineView.collapseItem(nil, collapseChildren: true)
            self.outlineView.expandItem(theList)
            self.outlineView.expandItem(theUnit)
            self.outlineView.expandItem(theWord)
            let row = self.outlineView.row(forItem: theWord)
            self.outlineView.selectRowIndexes(NSIndexSet(index: row) as IndexSet, byExtendingSelection: false)
            self.outlineView.scrollRowToVisible(row)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return item is Word
    }
}
