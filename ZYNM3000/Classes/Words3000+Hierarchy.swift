//
//  Words3000+Hierarchy.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 20/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Foundation

extension Words3000 {
    func hierarchyLists(callback: (([HierarchyList])->())) {
        queue.inDatabase { (db) in
            guard let db = db else {
                return
            }
            
            var hierarchyLists = [HierarchyList]()
            
            let sql = "SELECT DISTINCT(list) FROM wordlist ORDER BY list"
            let result = db.executeQuery(sql, withParameterDictionary: [NSObject: AnyObject]())
            while result?.next() == true {
                let list = Int((result?.int(forColumn: "list"))!)
                
                var units = [Int]()
                
                let sql = "SELECT DISTINCT(unit) FROM wordlist WHERE list = ? ORDER BY unit"
                let result1 = db.executeQuery(sql, withArgumentsIn: [list])
                while result1?.next() == true {
                    let unit = Int((result1?.int(forColumn: "unit"))!)
                    units.append(unit)
                }
                
                let hierarchyList = HierarchyList(id: list, unitIds: units)
                
                for hierarchyUnit in hierarchyList.units {
                    
                    var words = [Word]()
                    
                    let sql = "SELECT * FROM wordlist WHERE list = ? AND unit = ? ORDER BY `order`"
                    let result2 = db.executeQuery(sql, withArgumentsIn: [list, hierarchyUnit.id])
                    while result2?.next() == true {
                        let word = self.parseWord(result: result2!)
                        words.append(word)
                    }

                    hierarchyUnit.words = words
                }
                
                hierarchyLists.append(hierarchyList)
            }
            
            callback(hierarchyLists)
        }
    }
}

class HierarchyList {
    var id: Int
    var units: [HierarchyUnit]
    init(id: Int, unitIds: [Int]) {
        self.id = id
        self.units = [HierarchyUnit]()
        for unitId in unitIds {
            units.append(HierarchyUnit(list: self, id: unitId))
        }
    }
}

class HierarchyUnit {
    weak var list: HierarchyList?
    var id: Int
    var words: [Word]!
    init(list: HierarchyList, id: Int) {
        self.list = list
        self.id = id
    }
}
