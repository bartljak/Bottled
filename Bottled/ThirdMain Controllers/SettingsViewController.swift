//
//  SettingsViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/5/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var pincodeSwitch: UISwitch!
    @IBOutlet weak var faceIDSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        
        if(isKeyPresentInUserDefaults(key: "UsePinCode") == false){
            defaults.set(false, forKey: "UsePinCode")
        }
        
        if(isKeyPresentInUserDefaults(key: "UseFaceID") == false){
            defaults.set(false, forKey: "UseFaceID")
        }
        
        let usePinCode = defaults.bool(forKey: "UsePinCode")
        let useFaceID = defaults.bool(forKey: "UseFaceID")
        
        if(useFaceID == true)
        {
            faceIDSwitch.setOn(true, animated: false)
        }
        else
        {
            faceIDSwitch.setOn(false, animated: false)
        }
        
        if(usePinCode == true)
        {
            pincodeSwitch.setOn(true, animated: false)
        }
        else
        {
            pincodeSwitch.setOn(false, animated: false)
        }
    }
    
    @IBAction func changeFaceIDSetting(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(faceIDSwitch.isOn, forKey: "UseFaceID")
        
    }
    
    @IBAction func changePinCodeSetting(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        if(pincodeSwitch.isOn)
        {
            self.performSegue(withIdentifier: "settingsToPincode", sender: self)
        }
        else
        {
            defaults.set(false, forKey: "UsePinCode")
            defaults.set("", forKey: "Pincode")
        }
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    

}
