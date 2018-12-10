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

    @IBOutlet weak var email: UITextField!
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

        email.inputAccessoryView = keyboardToolBar
        password.inputAccessoryView = keyboardToolBar
        passwordConfirm.inputAccessoryView = keyboardToolBar
    }

    @objc func doneClicked() {
        view.endEditing(true)
    }

    @IBAction func signUpAction(_ sender: Any) {

        if self.password.text != self.passwordConfirm.text {

            let alertController = UIAlertController(title: "Password Incorrect",
                                                    message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {

            let username = email.text! + "@bottled.com"

            Auth.auth().createUser(withEmail: username, password: password.text!) { (_, error) in
                if error == nil {

                    let defaults = UserDefaults.standard
                    defaults.set(self.email.text!, forKey: "Username")
                    defaults.set(true, forKey: "LoggedIn")

                    let query = Constants.Refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: self.email.text)
                    query.observe(.value, with: { (snapshot) in

                        if snapshot.childrenCount == 1 {
                            for childSnapshot in snapshot.children {
                                let snap = childSnapshot as! DataSnapshot
                                defaults.set(snap.key, forKey: "UserUID")
                            }

                            self.performSegue(withIdentifier: "loginToHome", sender: self)
                        } else {
                            print("Error: more or less than one userID found for that username")
                        }
                    })

                    self.performSegue(withIdentifier: "signupToHome", sender: self)

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
