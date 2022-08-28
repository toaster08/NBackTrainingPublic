//
//  HalfModalViewController.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/06/02.
//

import UIKit

class RuleDescriptionViewController: UIViewController {
    //locarizedString
    let gameRuleLocarizedString = "ruleDescription"
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let locarizableString = NSLocalizedString(gameRuleLocarizedString, comment: "locarized game rule description")
        textView.text = locarizableString
    }
}


