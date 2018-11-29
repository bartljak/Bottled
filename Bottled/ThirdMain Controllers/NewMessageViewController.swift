//
//  NewMessageViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/28/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit

class NewMessageViewController: UIViewController {

    @IBOutlet weak var messageBody: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receipientField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendButton.layer.cornerRadius = 5
        sendButton.layer.borderWidth = 0
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        messageBody.inputAccessoryView = keyboardToolBar
        receipientField.inputAccessoryView = keyboardToolBar

        // Do any additional setup after loading the view.
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }


    @IBAction func sendButtonCliced(_ sender: Any) {
        
        //code for whe send button is clicked goes here
        
    }
    
}
