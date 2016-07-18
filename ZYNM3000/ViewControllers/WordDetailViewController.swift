//
//  WordDetailViewController.swift
//  ZYNM3000
//
//  Created by Xinhong LIU on 18/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import Cocoa

class WordDetailViewController: NSViewController {
    
    weak var containerViewController: ViewController!
    
    var word: Word!

    @IBOutlet weak var spellingLabel: NSTextField!
    @IBOutlet weak var speakerImageButton: NSButton!
    @IBOutlet weak var phoneticLabel: NSTextField!
    var englishMeaningTextView: NSTextView {
        get {
            return englishMeaningScrollView.contentView.documentView as! NSTextView
        }
    }
    var chineseMeaningTextView: NSTextView {
        get {
            return chineseMeaningScrollView.contentView.documentView as! NSTextView
        }
    }
    
    @IBOutlet weak var englishMeaningScrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chineseMeaningScrollViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var englishMeaningScrollView: NSScrollView!
    
    @IBOutlet weak var chineseMeaningScrollView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alphaValue = 0.0
        
        self.speakerImageButton.action = #selector(playSound)
        self.speakerImageButton.target = self
    }
    
    var appLaunching = true
    
    override func viewDidAppear() {
        super.viewDidAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(showLastWord), name: "left-arrow-key-pressed" as NSNotification.Name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNextWord), name: "right-arrow-key-pressed" as NSNotification.Name, object: nil)
        
        if appLaunching {
            appLaunching = false
            // load last record
            if let lastTimeWord = UserDefaults.standard.array(forKey: "last-time-word") as? [Int] {
                if let word = containerViewController.words3000.word(list: lastTimeWord[0], unit: lastTimeWord[1], orderInUnit: lastTimeWord[2]) {
                    displayWord(word: word)
                }
            }
        }
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self, name: "left-arrow-key-pressed" as NSNotification.Name, object: nil)
        NotificationCenter.default.removeObserver(self, name: "right-arrow-key-pressed" as NSNotification.Name, object: nil)
        // save progress
        UserDefaults.standard.set([word.list, word.unit, word.orderInUnit], forKey: "last-time-word")
        super.viewDidDisappear()
    }
    
    func displayWord(word: Word) {
        self.word = word
        reloadData()
        playSound()
        NotificationCenter.default.post(name: "word-displayed" as NSNotification.Name, object: nil, userInfo: ["list": word.list, "unit": word.unit, "orderInUnit": word.orderInUnit])
    }
    
    func playSound() {
        self.word.playSound()
    }
    
    func adjustTextViewScrollViewHeight(scrollView: NSScrollView, heightConstraint: NSLayoutConstraint) {
        let textView = scrollView.contentView.documentView as! NSTextView
        textView.layoutManager?.glyphRange(for: textView.textContainer!)
        let height = textView.layoutManager?.usedRect(for: textView.textContainer!).size.height
        heightConstraint.constant = height!
    }
    
    func reloadData() {
        self.view.alphaValue = 1.0
        
        spellingLabel.stringValue = word.spelling
        phoneticLabel.attributedStringValue = parseHTMLString(html: word.phonetic, font: NSFont(name: "Palatino-Roman", size: 14.0)!)
        englishMeaningTextView.textStorage?.setAttributedString(parseHTMLString(html: word.englishMeaning.replacingOccurrences(of: "|", with: "<br />"), font: NSFont(name: "Palatino-Roman", size: 22.0)!))
        chineseMeaningTextView.textStorage?.setAttributedString(parseHTMLString(html: word.chineseMeaning.replacingOccurrences(of: "|", with: "<br />"), font: NSFont(name: "Heiti SC", size: 22.0)!))
        adjustTextViewScrollViewHeight(scrollView: englishMeaningScrollView, heightConstraint: englishMeaningScrollViewHeightConstraint)
        adjustTextViewScrollViewHeight(scrollView: chineseMeaningScrollView, heightConstraint: chineseMeaningScrollViewHeightConstraint)
    }
    
    private func parseHTMLString(html: String, font: NSFont) -> AttributedString {
        let data = html.data(using: String.Encoding.unicode)
        let attributedString = NSMutableAttributedString(html: data!, baseURL: URL(string: "https://xinhong.me")!, documentAttributes: nil)
        
        // make font bigger and center alignment
        attributedString?.addAttribute(NSFontAttributeName, value: font, range: NSMakeRange(0, attributedString!.length))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        attributedString?.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedString!.length))
        
        return attributedString!
    }
    
    func incrementWord(word: Word, positive: Bool) -> Word {
        var list = word.list
        var unit = word.unit
        var orderInUnit = word.orderInUnit
        if positive {
            orderInUnit += 1
            if orderInUnit > 10 {
                orderInUnit = 1
                unit += 1
                if unit > 10 {
                    unit = 1
                    list += 1
                }
            }
        } else {
            orderInUnit -= 1
            if orderInUnit < 1 {
                orderInUnit = 10
                unit -= 1
                if unit < 1 {
                    unit = 10
                    list -= 1
                    if list < 1 {
                        return word
                    }
                }
            }
        }
        if let word = containerViewController.words3000.word(list: list, unit: unit, orderInUnit: orderInUnit) {
            return word
        }
        return word
    }
    
    func showLastWord() {
        displayWord(word: incrementWord(word: word, positive: false))
    }
    
    func showNextWord() {
        displayWord(word: incrementWord(word: word, positive: true))
    }
}
