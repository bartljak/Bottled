//
//  TabbedChatViewController.swift
//  Bottled
//
//  Created by Christopher Pybus on 11/5/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class MessagesTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!

    var convoID: String!
    
    var otherParticipantsUIDs: [String] = []
    var otherParticipantsUsernames: [String] = []
}

class MyMessagesViewController: UIViewController {

    @IBOutlet weak var newMessageButton: UIButton!
    @IBOutlet weak var editMessagesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var userID: String = ""
    var username: String = ""
    var conversationIDs: [String] = []
    var lastMessageInEachConvo: [String: String] = [:]
    var lastTimestampInEachConvo: [String: Double] = [:]
    var otherParticipantUsername: [String: String] = [:]
    var otherParticipantUserUID: [String: String] = [:]
    var selectedConvoID: String = ""
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        newMessageButton.layer.cornerRadius = 5
        newMessageButton.layer.borderWidth = 0

        editMessagesButton.layer.cornerRadius = 5
        editMessagesButton.layer.borderWidth = 0

        let defaults = UserDefaults.standard
        username = defaults.string(forKey: "Username")!
        userID = defaults.string(forKey: "UserUID")!

        getConversations(userID: userID, username: username)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    @objc private func refreshWeatherData(_ sender: Any) {
        // Fetch Weather Data
        tableView.reloadData()
        self.refreshControl.endRefreshing()
    }

    //Wil get the UID of any given username. Not used anymore because userUID is configured upon login.
    @available(*, deprecated, message: "No longer needed because user UID is set to user defaults on login.")
    func getUserID(username: String) {
        //print("got here!")
        let query = Constants.Refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: username)
        query.observe(.value, with: { (snapshot) in

            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                self.userID = snap.key
            }
            
            query.removeAllObservers()

            //print("Here is the returned userID:")
            //print(self.userID)
            self.getConversations(userID: self.userID, username: username)
        })
    }

    //Will get the conversationUID of all conversations a user participants in, when given user UID and username
    func getConversations(userID: String, username: String) {
        let query = Constants.Refs.databaseConvo.queryOrdered(byChild: userID).queryEqual(toValue: username)
        query.observe(.value, with: { (snapshot) in

            //print(snapshot)  //prints out all the returned conversations,
            // which is all conversations filtered by user UID
            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                self.conversationIDs.append(snap.key)
                self.getMessagesInConvo(convoUID: snap.key)

                for children2 in snap.children {
                    let snap2 = children2 as! DataSnapshot
                    let otherUsername = snap2.value as! String
                    if otherUsername != username {
                        self.otherParticipantUsername[snap.key] = otherUsername
                        self.otherParticipantUserUID[snap.key] = snap2.key
                        //print("Got here!", otherUsername)
                    }
                }
                //print(self.otherParticipantUsername)
                //print(self.otherParticipantUserUID)
            }

            query.removeAllObservers()
        })
    }

    //Will get the messageUID of all messages in a conversation
    func getMessagesInConvo(convoUID: String) {
        let query = Constants.Refs.databaseMssgs.queryOrdered(byChild: "convo").queryEqual(toValue: convoUID)
        query.observe(.value, with: { (snapshot) in

            var time: Double = 0
            var payload: String = ""

            //print("For convo: ", convoUID, " here are the messages:" )
            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot

                let tempPayload = snap.childSnapshot(forPath: "payload").value as! String
                let tempTime = snap.childSnapshot(forPath: "timestamp").value as! Double

                if tempTime > time {
                    time = tempTime
                    payload = tempPayload
                }

            }

            self.lastMessageInEachConvo[convoUID] = payload
            self.lastTimestampInEachConvo[convoUID] = time
            self.tableView.reloadData()

            //print(convoUID, ": ", payload)

            query.removeAllObservers()
        })

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension MyMessagesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath) as! MessagesTableViewCell
        let convoID = self.conversationIDs[indexPath.row]

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"

        let myString =
            formatter.string(from: NSDate(timeIntervalSince1970: self.lastTimestampInEachConvo[convoID]!/1000) as Date)

        cell.convoID = convoID
        cell.nameLabel?.text = self.otherParticipantUsername[convoID]
        cell.messageLabel?.text = self.lastMessageInEachConvo[convoID]
        cell.timeLabel?.text = myString
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("You selected cell #\(indexPath.row)!")
        let messageCell = tableView.cellForRow(at: indexPath) as! MessagesTableViewCell
        //print("convo id: ", messageCell.convoID)
        let defaults = UserDefaults.standard
        defaults.set(messageCell.convoID, forKey: "selectedconvo")
        self.performSegue(withIdentifier: "messagesToChatView", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
