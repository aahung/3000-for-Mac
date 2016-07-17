//
//  TestMethod.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 17/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Foundation

class TestMethod {
    var title: String
    var content: String
    var exampleSentence: String?
    var synonym: String?
    var antonym: String?
    
    init(json: [String: AnyObject]) {
        self.title = json["father"] as! String
        self.content = json["fatherContent"] as! String
        for child in json["children"] as! [AnyObject] {
            let childObject = child as! [String: AnyObject]
            if let exampleSentence = childObject["例"] as? String {
                self.exampleSentence = exampleSentence
            }
            if let synonym = childObject["近"] as? String {
                self.synonym = synonym
            }
            if let antonym = childObject["反"] as? String {
                self.antonym = antonym
            }
        }
    }
}
