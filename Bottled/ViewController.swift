//
//  ViewController.swift
//  Bottled
//
//  Created by Jake Bartles on 10/16/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signinButton.layer.cornerRadius = 10
        signinButton.clipsToBounds = true
        
        signupButton.layer.cornerRadius = 10
        signupButton.clipsToBounds = true
    }

    @IBAction func showMessage(sender: UIButton) {
        let alertController = UIAlertController(title: "Welcome to My First App", message: "Hello World", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

