//
//  HierarchyViewController.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 18/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class HierarchyViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var lists = [HierarchyList]()

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
        Words3000.shared.hierarchyLists(callback: { (lists) in
            self.lists = lists
            OperationQueue.main.addOperation {
                self.outlineView.reloadData()
            }
        })
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
            } else if item is HierarchyUnit {
                return (item as! HierarchyUnit).words.count
            } else if item is HierarchyList {
                return (item as! HierarchyList).units.count
            } else {
                fatalError()
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if item == nil {
            return lists[index]
        } else {
            if item is HierarchyUnit {
                return (item as! HierarchyUnit).words[index]
            } else if item is HierarchyList {
                return (item as! HierarchyList).units[index]
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
            } else if item is HierarchyUnit {
                cell?.textField?.stringValue = "Unit \((item as! HierarchyUnit).id)"
            } else if item is HierarchyList {
                cell?.textField?.stringValue = "List \((item as! HierarchyList).id)"
            } else {
                fatalError()
            }
            
            return cell
        } else if tableColumn?.identifier == "outline-button-column" {
            let cell = outlineView.make(withIdentifier: "outline-button-cell", owner: self) as? OutlineButtonView
            
            var id = 0
            cell?.goButton.isHidden = false
            if item is Word {
                cell?.goButton.isHidden = true
                id = (item as! Word).list * 10000 + (item as! Word).unit * 100 + (item as! Word).orderInUnit
            } else if item is HierarchyUnit {
                id = (item as! HierarchyUnit).list!.id * 10000 + (item as! HierarchyUnit).id * 100
            } else if item is HierarchyList {
                id = (item as! HierarchyList).id * 10000
            }
            
            cell?.goButton.tag = id
            cell?.goButton.target = self
            cell?.goButton.action = #selector(goButtonClicked(sender:))
            
            return cell
        }
        
        return nil
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        let outlineView = notification.object as! NSOutlineView
        let item = outlineView.item(atRow: outlineView.selectedRow)
        if let word = item as? Word {
            print("outlineViewSelectionDidChange: \([word.list, word.unit, word.orderInUnit])")
            NotificationCenter.default.post(Notification(name: "select-word-in-hierarchy" as Notification.Name, object: nil, userInfo: ["word": word]))
        }
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
        Words3000.shared.word(list: list, unit: unit, orderInUnit: orderInUnit, callback: { (word) in
            if let word = word {
                NotificationCenter.default.post(Notification(name: "select-word-in-hierarchy" as Notification.Name, object: nil, userInfo: ["word": word]))
            }
        })
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
        if item is Word {
            return true
        } else {
            return false
        }
    }
}
