//
//  Words3000.swift
//  再要你命 3000
//
//  Created by Xinhong LIU on 17/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Foundation
import FMDB

class Words3000 {
    var queue: FMDatabaseQueue!
    
    static let shared: Words3000 = {
        return Words3000()
    }()
    
    init() {
        let dbFilePath = Bundle.main.pathForResource("Resources/GREWord.sqlite", ofType: nil)
        queue = FMDatabaseQueue(path: dbFilePath)
    }
    
    func lists(callback: (([Int])->())) {
        queue.inDatabase { (db) in
            guard let db = db else {
                return
            }
            var lists = [Int]()
            
            let sql = "SELECT DISTINCT(list) FROM wordlist ORDER BY list"
            let result = db.executeQuery(sql, withParameterDictionary: [NSObject: AnyObject]())
            while result?.next() == true {
                let list = Int((result?.int(forColumn: "list"))!)
                lists.append(list)
            }
            
            callback(lists)
        }
    }
    
    func units(list: Int, callback: (([Int])->())) {
        queue.inDatabase { (db) in
            guard let db = db else {
                return
            }
            var units = [Int]()
            
            let sql = "SELECT DISTINCT(unit) FROM wordlist WHERE list = ? ORDER BY unit"
            let result = db.executeQuery(sql, withArgumentsIn: [list])
            while result?.next() == true {
                let unit = Int((result?.int(forColumn: "unit"))!)
                units.append(unit)
            }
            
            callback(units)
        }
    }
    
    func words(list: Int, unit: Int, callback: (([Word])->())) {
        queue.inDatabase { (db) in
            guard let db = db else {
                return
            }
            var words = [Word]()
            
            let sql = "SELECT * FROM wordlist WHERE list = ? AND unit = ? ORDER BY `order`"
            let result = db.executeQuery(sql, withArgumentsIn: [list, unit])
            while result?.next() == true {
                let word = self.parseWord(result: result!)
                words.append(word)
            }
            
            callback(words)
        }
    }
    
    func words(like: String, callback: (([Word])->())) {
        queue.inDatabase { (db) in
            guard let db = db else {
                return
            }
            var words = [Word]()
            
            let sql = "SELECT * FROM wordlist WHERE content LIKE ? ORDER BY `order`"
            let result = db.executeQuery(sql, withArgumentsIn: ["%\(like.lowercased())%"])
            while result?.next() == true {
                let word = self.parseWord(result: result!)
                words.append(word)
            }
            
            callback(words)
        }
    }
    
    func word(list: Int, unit: Int, orderInUnit: Int, callback: ((Word?)->())) {
        queue.inDatabase { (db) in
            guard let db = db else {
                return
            }
            let sql = "SELECT * FROM wordlist WHERE list = ? AND unit = ? AND `order` = ?"
            let result = db.executeQuery(sql, withArgumentsIn: [list, unit, orderInUnit])
            guard result?.next() == true else {
                callback(nil)
                return
            }
            callback(self.parseWord(result: result!))
        }
    }
    
    func parseWord(result: FMResultSet) -> Word {
        let id = Int(result.int(forColumn: "id"))
        let spelling = result.string(forColumn: "content")!
        let content = result.string(forColumn: "complet")!
        let phonetic = result.string(forColumn: "phonetic")!
        let chineseMeaning = result.string(forColumn: "chinese")!
        let englishMeaning = result.string(forColumn: "english")!
        let list = Int(result.int(forColumn: "list"))
        let unit = Int(result.int(forColumn: "unit"))
        let orderInUnit = Int(result.int(forColumn: "order"))
        
        let word = Word(id: id, spelling: spelling, content: content, phonetic: phonetic, chineseMeaning: chineseMeaning, englishMeaning: englishMeaning, list: list, unit: unit, orderInUnit: orderInUnit)
        return word
    }
}
