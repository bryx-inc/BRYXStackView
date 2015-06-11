//
//  ViewController.swift
//  StackView
//
//  Created by Harlan Haskins on 06/11/2015.
//  Copyright (c) 06/11/2015 Harlan Haskins. All rights reserved.
//

import UIKit
import BRYXStackView

class ViewController: UIViewController {
    
    @IBOutlet weak var stackView: StackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stackView.batchUpdates({
            self.addLabel(text: "Hello, World", toStackView: self.stackView, backgroundColor: UIColor.lightGrayColor())
            self.addLabel(text: "Stacked views!", toStackView: self.stackView,  backgroundColor: UIColor.greenColor())
            self.addLabel(text: "Are pretty cool...", toStackView: self.stackView,  backgroundColor: UIColor.cyanColor())
            let newStack = StackView()
            newStack.backgroundColor = UIColor(white: 0.85, alpha: 1.0)
            newStack.batchUpdates({
                self.addLabel(text: "Nested StackViews", toStackView: newStack,  backgroundColor: UIColor.orangeColor())
                self.addLabel(text: "totally work", toStackView: newStack,  backgroundColor: UIColor.redColor())
                self.addLabel(text: "as well", toStackView: newStack,  backgroundColor: UIColor.yellowColor())
            })
            self.stackView.addSubview(newStack, withEdgeInsets: UIEdgeInsets(top: 10.0, left: 25.0, bottom: 10.0, right: 25.0))
        })
    }
    
    func addLabel(#text: String, toStackView stackView: StackView, backgroundColor: UIColor = UIColor.whiteColor()) {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.backgroundColor = backgroundColor
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        stackView.addSubview(label, withEdgeInsets: UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0))
    }
    
}

