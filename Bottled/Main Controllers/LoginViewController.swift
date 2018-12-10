//
//  LoginViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/4/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 0
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        email.inputAccessoryView = keyboardToolBar
        password.inputAccessoryView = keyboardToolBar
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }

    @IBAction func loginAction(_ sender: Any) {
        
        let username = email.text! + "@bottled.com"
        
        Auth.auth().signIn(withEmail: username, password: password.text!) { (user, error) in
            if error == nil{
                
                let defaults = UserDefaults.standard
                defaults.set(self.email.text!, forKey: "Username")
                defaults.set(true, forKey: "LoggedIn")
                
                
                let query = Constants.refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: self.email.text)
                query.observe(.value, with: { (snapshot) in
                    
                    if(snapshot.childrenCount == 1){
                        for childSnapshot in snapshot.children {
                            let snap = childSnapshot as! DataSnapshot
                            defaults.set(snap.key, forKey: "UserUID")
                        }
                        
                        self.performSegue(withIdentifier: "loginToHome", sender: self)
                    }
                    else{
                        print("Error: more or less than one userID found for that username");
                    }
                })
                
                
                
            }
            else{
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
