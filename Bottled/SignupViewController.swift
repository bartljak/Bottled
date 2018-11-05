//
//  SignupViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/4/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignupViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    @IBOutlet weak var SignupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SignupButton.layer.cornerRadius = 5
        SignupButton.layer.borderWidth = 0
    
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
        if password.text != passwordConfirm.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            let username = email.text! + "@bottled.com"
            
            Auth.auth().createUser(withEmail: username, password: password.text!){ (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signupToHome", sender: self)
                    let defaults = UserDefaults.standard
                    defaults.set(username, forKey: "Username")
                    defaults.set(true, forKey: "LoggedIn")
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    

}
