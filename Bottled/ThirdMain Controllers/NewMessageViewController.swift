//
//  NewMessageViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/28/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController {

    @IBOutlet weak var messageBody: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var receipientField: UITextField!
    
    var myVariable = "";
    
    var receipentID = "";
    var userUID: String = "";
    var username: String = "";
    
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
        
        receipientField.text = myVariable;

        let defaults = UserDefaults.standard
        userUID = defaults.string(forKey: "UserUID")
        username = defaults.string(forKey: "Username")
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
        
        
    }


    @IBAction func sendButtonCliced(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil) //dismisses model
        
        getUIDOfReceipient()
            
    }
    
    func getUIDOfReceipient()
    {
        let query = Constants.refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: self.receipientField.text)
        query.observe(.value, with: { (snapshot) in
            if(snapshot.childrenCount == 1){
                for childSnapshot in snapshot.children {
                    let snap = childSnapshot as! DataSnapshot
                    self.receipentID = snap.key
                }
                
                self.getConversationWithBoth()
            }
            else{
                print("Error: more or less than one userID found for that username");
            }
            
        })
    }
    
    
    func getConversationWithBoth()
    {
        let query2 = Constants.refs.databaseConvo.queryOrdered(byChild: self.userUID).queryEqual(toValue: self.username)
        query2.observe(.value, with: { (snapshot) in
            print("convoIDs:")
            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                conversationIDs.append(snap.key)
                print(snap.key)
                
                let query3 = Constants.refs.databaseMssgs.queryOrdered(byChild: "convo").queryEqual(toValue: snap.key)
                query3.observe(.value, with: { (snapshot) in
                    print("  messageIDs in that convo:")
                    for childSnapshot3 in snapshot.children {
                        let snap3 = childSnapshot3 as! DataSnapshot
                        conversationIDs.append(snap3.key)
                        print("  ", snap3.key)
                    }
                })
            }
        })
    }
    
    
}
