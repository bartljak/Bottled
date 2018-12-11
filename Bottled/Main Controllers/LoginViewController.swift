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

    @IBOutlet weak var usernameField: UITextField!
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

        usernameField.inputAccessoryView = keyboardToolBar
        password.inputAccessoryView = keyboardToolBar
    }

    @objc func doneClicked() {
        view.endEditing(true)
    }

    @IBAction func loginAction(_ sender: Any) {

        let username: String = self.usernameField.text!
        let usernameWithEmail = username + "@bottled.com"
        let pass: String = self.password.text!

        Auth.auth().signIn(withEmail: usernameWithEmail, password: pass) { (_, error) in
            if error == nil {

                let defaults = UserDefaults.standard
                defaults.set(username, forKey: "Username")
                defaults.set(true, forKey: "LoggedIn")

                let query = Constants.Refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: username)
                query.observe(.value, with: { (snapshot) in

                    for childSnapshot in snapshot.children {
                        let snap = childSnapshot as! DataSnapshot
                        defaults.set(snap.key, forKey: "UserUID")
                    }

                    query.removeAllObservers()
                    self.performSegue(withIdentifier: "loginToHome", sender: self)
                })
            } else {
                let alertController =
                    UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
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
