//
//  PincodeViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/5/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit

class PincodeViewController: UIViewController {

    @IBOutlet weak var pincodeField: UITextField!
    @IBOutlet weak var setPincodeButton: UIButton!
    @IBOutlet weak var pincodeConfirmField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPincodeButton.layer.cornerRadius = 5
        setPincodeButton.layer.borderWidth = 0

        self.pincodeField.keyboardType = UIKeyboardType.decimalPad
        self.pincodeConfirmField.keyboardType = UIKeyboardType.decimalPad
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        pincodeField.inputAccessoryView = keyboardToolBar
        pincodeConfirmField.inputAccessoryView = keyboardToolBar
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    @IBAction func setpincodeFunc(_ sender: Any) {
        
        if( pincodeField.text != pincodeConfirmField.text )
        {
            let alertController = UIAlertController(title: "Pincode Doesnt Match", message: "Please re-type pincode", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "UsePinCode")
            defaults.set(pincodeField.text, forKey: "Pincode")
            
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    

}
