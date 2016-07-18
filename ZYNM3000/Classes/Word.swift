//
//  Word.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 17/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Foundation
import FMDB

class Word: Equatable {
    var id: Int
    var spelling: String
    var testMethods: [TestMethod]
    var phonetic: String
    var chineseMeaning: String
    var englishMeaning: String
    
    var list: Int
    var unit: Int
    var orderInUnit: Int
    
    init(id: Int, spelling: String, content: String, phonetic: String, chineseMeaning: String, englishMeaning: String, list: Int, unit: Int, orderInUnit: Int) {
        self.id = id
        self.spelling = spelling
        self.phonetic = phonetic
        self.chineseMeaning = chineseMeaning
        self.englishMeaning = englishMeaning
        self.testMethods = [TestMethod]()
        
        self.list = list
        self.unit = unit
        self.orderInUnit = orderInUnit
        
        do {
            let contents = try JSONSerialization.jsonObject(with: content.data(using: .utf8)!, options: .allowFragments) as! [AnyObject]
            for content in contents {
                let contentObject = content as! [String: AnyObject]
                let valueObject = contentObject.values.first as! [String: AnyObject]
                self.testMethods.append(TestMethod(json: valueObject))
            }
        } catch {
            print("Should be any error here, DAMN!")
        }
    }
    
    func playSound() {
        let audioPath = Bundle.main.pathForResource("Resources/Audio/\(id).wav", ofType: nil)
        let sound = NSSound(contentsOfFile: audioPath!, byReference: true)
        sound?.play()
    }
}

func ==(lhs: Word, rhs: Word) -> Bool {
    return lhs.list == rhs.list && lhs.unit == rhs.unit && lhs.orderInUnit == rhs.orderInUnit
}
