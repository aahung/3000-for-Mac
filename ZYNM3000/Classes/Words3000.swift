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
    var db: FMDatabase!
    
    static let shared: Words3000 = {
        return Words3000()
    }()
    
    init() {
        let dbFilePath = Bundle.main.pathForResource("Resources/GREWord.sqlite", ofType: nil)
        db = FMDatabase(path: dbFilePath)
        if !db.open() {
            print("DB is not open: \(db.lastErrorMessage()!)")
        }
    }
    
    func lists() -> [Int] {
        var lists = [Int]()
        
        let sql = "SELECT DISTINCT(list) FROM wordlist ORDER BY list"
        let result = db.executeQuery(sql, withParameterDictionary: [NSObject: AnyObject]())
        while result?.next() == true {
            let list = Int((result?.int(forColumn: "list"))!)
            lists.append(list)
        }
        
        return lists
    }
    
    func units(list: Int) -> [Int] {
        var units = [Int]()
        
        let sql = "SELECT DISTINCT(unit) FROM wordlist WHERE list = ? ORDER BY unit"
        let result = db.executeQuery(sql, withArgumentsIn: [list])
        while result?.next() == true {
            let unit = Int((result?.int(forColumn: "unit"))!)
            units.append(unit)
        }
        
        return units
    }
    
    func words(list: Int, unit: Int) -> [Word] {
        var words = [Word]()
        
        let sql = "SELECT * FROM wordlist WHERE list = ? AND unit = ? ORDER BY `order`"
        let result = db.executeQuery(sql, withArgumentsIn: [list, unit])
        while result?.next() == true {
            let word = parseWord(result: result!)
            words.append(word)
        }
        
        return words
    }
    
    func words(like: String) -> [Word] {
        var words = [Word]()
        
        let sql = "SELECT * FROM wordlist WHERE content LIKE ? ORDER BY `order`"
        let result = db.executeQuery(sql, withArgumentsIn: ["%\(like.lowercased())%"])
        while result?.next() == true {
            let word = parseWord(result: result!)
            words.append(word)
        }
        
        return words
    }
    
    func word(list: Int, unit: Int, orderInUnit: Int) -> Word? {
        let sql = "SELECT * FROM wordlist WHERE list = ? AND unit = ? AND `order` = ?"
        let result = db.executeQuery(sql, withArgumentsIn: [list, unit, orderInUnit])
        guard result?.next() == true else {
            return nil
        }
        return parseWord(result: result!)
    }
    
    private func parseWord(result: FMResultSet) -> Word {
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
