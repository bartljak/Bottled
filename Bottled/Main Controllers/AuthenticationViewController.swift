//
//  AuthenticationViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/5/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {

    @IBOutlet weak var unlockAppButton: UIButton!
    @IBOutlet weak var pinCodeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard

        if isKeyPresentInUserDefaults(key: "LoggedIn") == false {
            defaults.set(false, forKey: "LoggedIn")
        }

        if isKeyPresentInUserDefaults(key: "UsePinCode") == false {
            defaults.set(false, forKey: "UsePinCode")
        }

        if isKeyPresentInUserDefaults(key: "UseFaceID") == false {
            defaults.set(false, forKey: "UseFaceID")
        }

        if isKeyPresentInUserDefaults(key: "Pincode") == false {
            defaults.set("", forKey: "Pincode")
        }

        let usePinCode = defaults.bool(forKey: "UsePinCode")
        let useFaceID = defaults.bool(forKey: "UseFaceID")

        if useFaceID == false {
            unlockAppButton.backgroundColor = UIColor(red: 151/255, green: 74/255, blue: 73/255, alpha: 1)
        } else {
            unlockAppButton.backgroundColor = UIColor(red: 188/255, green: 70/255, blue: 65/255, alpha: 1)
        }

        if usePinCode == false {
            pinCodeButton.backgroundColor = UIColor(red: 151/255, green: 74/255, blue: 73/255, alpha: 1)
        } else {
            pinCodeButton.backgroundColor = UIColor(red: 188/255, green: 70/255, blue: 65/255, alpha: 1)
        }

        unlockAppButton.layer.cornerRadius = 5
        unlockAppButton.layer.borderWidth = 0

        pinCodeButton.layer.cornerRadius = 5
        pinCodeButton.layer.borderWidth = 0

    }

    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let usePinCode = defaults.bool(forKey: "UsePinCode")
        let useFaceID = defaults.bool(forKey: "UseFaceID")
        let loggedIn = defaults.bool(forKey: "LoggedIn")

        if loggedIn == true //user is logged in, check if pincode/faceid enbaled
        {
            if usePinCode == false && useFaceID == false {
                //no authentication enbaled, move to navigation
                self.performSegue(withIdentifier: "authToNav", sender: self)
            }
        } else //nobody logged in, move to signin screens
        {
            if useFaceID == false && usePinCode == false {
                self.performSegue(withIdentifier: "authToSignupSignin", sender: self)
            }
        }

    }

    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func pinCodePress(_ sender: Any) {
        let defaults = UserDefaults.standard

        if isKeyPresentInUserDefaults(key: "UsePinCode") == false {
            defaults.set(false, forKey: "UsePinCode")
        }

        let usePinCode = defaults.bool(forKey: "UsePinCode")

        if usePinCode == true {
            self.performSegue(withIdentifier: "authToPincode", sender: self)
        }
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        let defaults = UserDefaults.standard

        if isKeyPresentInUserDefaults(key: "UseFaceID") == false {
            defaults.set(false, forKey: "UseFaceID")
        }

        let useFaceID = defaults.bool(forKey: "UseFaceID")

        if useFaceID == true {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Unlock Application"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                       localizedReason: reason) { [unowned self] (success, _) in

                    DispatchQueue.main.async {
                        if success {
                            self.performSegue(withIdentifier: "authToNav", sender: self)
                        } else {
                            let alertController =
                                UIAlertController(title: "Authentication failed",
                                                  message: "You could not be verified; please try again.",
                                                  preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alertController, animated: true)
                        }
                    }
                }
            } else {
                let alertController =
                    UIAlertController(title: "Biometry unavailable",
                                      message: "Your device is not configured for biometric authentication.",
                                      preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alertController, animated: true)
            }
        }

    }

}
