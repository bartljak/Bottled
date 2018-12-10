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
    var convoUID: String = "";
    
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
        userUID = defaults.string(forKey: "UserUID")!
        username = defaults.string(forKey: "Username")!
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }


    @IBAction func sendButtonCliced(_ sender: Any) {
        
        let repUsername: String = self.receipientField.text!
        
        if(repUsername == "" || self.receipientField.text == nil)
        {
            let alertController = UIAlertController(title: "Error", message: "Recepient field is empty", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if(repUsername.contains(" "))
        {
            let alertController = UIAlertController(title: "Error", message: "Recepient field cannot have spaces", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else if(repUsername == "" || self.messageBody.text == nil)
        {
            let alertController = UIAlertController(title: "Error", message: "Message body is empty", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            getUIDOfReceipient()
        }
    }
    
    func getUIDOfReceipient()
    {
        let query = Constants.refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: self.receipientField.text)
        query.observe(.value, with: { (snapshot) in
            
            var found = false
            
            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                
                let repUsername: String = snap.value as! String
                if(repUsername == self.receipientField.text)
                {
                    //print("Heres the receipient:", snap.key)
                    self.receipentID = snap.key
                    found = true;
                    break
                }
            }
            
            query.removeAllObservers()
            
            if(found == false)
            {
                let alertController = UIAlertController(title: "Error", message: "Username not valid.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                self.getConversationWithBoth()
                self.dismiss(animated: true, completion: nil) //dismisses model
            }
            
            
        })
    }
    
    
    func getConversationWithBoth()
    {
        var foundMatch = false;
        let query2 = Constants.refs.databaseConvo.queryOrdered(byChild: self.userUID).queryEqual(toValue: self.username)
        query2.observe(.value, with: { (snapshot) in
            
            //print(snapshot)
            for childSnapAny in snapshot.children {
                let childSnap = childSnapAny as! DataSnapshot
                if(childSnap.childrenCount != 2)
                {
                    break;
                }
                
                var found1 = false;
                var found2 = false;
                
                for childSnap2 in childSnap.children{
                    let snap2 = childSnap2 as! DataSnapshot
                    if(snap2.key == self.userUID)
                    {
                        found1 = true;
                    }
                    else if(snap2.key == self.receipentID)
                    {
                        found2 = true;
                    }
                    else
                    {
                        break;
                    }
                }
                
                query2.removeAllObservers()
                
                if(found1 == true && found2 == true)
                {
                    //print("Here's the convo with both people: ", childSnap.key)
                    self.convoUID = childSnap.key
                    self.sendMessage()
                    foundMatch = true;
                    break;
                }
                
            }
            
            if(foundMatch == false) //create a new conversation
            {
                let key = Constants.refs.databaseConvo.childByAutoId().key
                let repUsername: String = self.receipientField.text!
                let childUpdates = [key: [self.userUID: self.username,
                                          self.receipentID: repUsername]]
                Constants.refs.databaseConvo.updateChildValues(childUpdates)
                
                self.convoUID = key!;
                self.sendMessage()
            }
        })
    }
    
    func sendMessage()
    {
        let key = Constants.refs.databaseMssgs.childByAutoId().key
        //let post = [key: users[i]]
        let childUpdates = [key: ["convo": self.convoUID,
                                  "payload": self.messageBody.text,
                                  "sender": self.username,
                                  "timestamp": [".sv":"timestamp"]
                                    ]
                            ]
        Constants.refs.databaseMssgs.updateChildValues(childUpdates)
        
        
    }
    
}
