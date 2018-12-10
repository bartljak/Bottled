//
//  PincodeLoginViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/5/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit

class PincodeLoginViewController: UIViewController {

    @IBOutlet weak var pincodeLoginButton: UIButton!
    @IBOutlet weak var pincodeField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        pincodeLoginButton.layer.cornerRadius = 5
        pincodeLoginButton.layer.borderWidth = 0

        self.pincodeField.keyboardType = UIKeyboardType.decimalPad

        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )

        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)

        pincodeField.inputAccessoryView = keyboardToolBar
    }

    @objc func doneClicked() {
        view.endEditing(true)
    }

    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    @IBAction func loginPincodeFunc(_ sender: Any) {

        let defaults = UserDefaults.standard
        let pincode = defaults.string(forKey: "Pincode")

        if pincodeField.text != pincode {
            let alertController = UIAlertController(title: "Pincode Doesnt Match",
                                                    message: "Please re-type pincode", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "pincodeAuthToNext", sender: self)
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
