//
//  TabbedChatViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/5/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
}

class MessagesViewController: UIViewController {

    @IBOutlet weak var newMessageButton: UIButton!
    @IBOutlet weak var editMessagesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newMessageButton.layer.cornerRadius = 5
        newMessageButton.layer.borderWidth = 0
        
        editMessagesButton.layer.cornerRadius = 5
        editMessagesButton.layer.borderWidth = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
