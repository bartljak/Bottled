//
//  SignupViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/4/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var signupButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        signupButton.layer.cornerRadius = 5
        signupButton.layer.borderWidth = 0

        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )

        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)

        usernameField.inputAccessoryView = keyboardToolBar
        password.inputAccessoryView = keyboardToolBar
        passwordConfirm.inputAccessoryView = keyboardToolBar
    }

    @objc func doneClicked() {
        view.endEditing(true)
    }

    @IBAction func signUpAction(_ sender: Any) {
        let username: String = self.usernameField.text!
        let usernameWithEmail: String = username + "@bottled.com"
        let pass: String = self.password.text!
        let passC: String = self.passwordConfirm.text!

        if pass != passC { //check if password matches confirm password
            let alertController = UIAlertController(title: "Password Incorrect",
                                                    message: "Please re-type password.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else if(username.contains(" ")) { //check is username has any spaces
            let alertController = UIAlertController(title: "Username Invalid",
                                                    message: "You cannot use spaces in your username.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{ //if neither of previous conditions are true, then goahead and attempt account creation
            Auth.auth().createUser(withEmail: usernameWithEmail, password: pass) { (_, error) in
                if error == nil {
                    let key = Constants.Refs.databaseUsers.childByAutoId().key
                    let childUpdates = [key: username]
                    Constants.Refs.databaseUsers.updateChildValues(childUpdates)
                    
                    let defaults = UserDefaults.standard
                    defaults.set(username, forKey: "Username") //set user defaults username
                    defaults.set(true, forKey: "LoggedIn") //set user defaults logged in
                    defaults.set(key, forKey: "UserUID") //set user defaults user unique ID
                    self.performSegue(withIdentifier: "signupToHome", sender: self) //segue to new view
                } else {
                    let alertController =
                        UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

}
