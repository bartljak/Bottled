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

}

class MessagesViewController: UIViewController {

    @IBOutlet weak var newMessageButton: UIButton!
    @IBOutlet weak var editMessagesButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var userID: String = ""
    var conversationIDs: [String] = []
    var lastMessageInEachConvo: [String: String] = [:]
    var lastTimestampInEachConvo: [String: Double] = [:]
    var otherParticipant: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        newMessageButton.layer.cornerRadius = 5
        newMessageButton.layer.borderWidth = 0

        editMessagesButton.layer.cornerRadius = 5
        editMessagesButton.layer.borderWidth = 0

        let defaults = UserDefaults.standard
        if isKeyPresentInUserDefaults(key: "Username") {
            let username = defaults.string(forKey: "Username")!
            //print(username)

            getUserID(username: username)
        }
    }

    @IBAction func testButton(_ sender: Any) {
        self.tableView.reloadData()
    }

    //Wil get the UID of any given username
    func getUserID(username: String) {
        //print("got here!")
        let query = Constants.Refs.databaseUsers.queryOrderedByValue().queryEqual(toValue: username)
        query.observe(.value, with: { (snapshot) in

            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                self.userID = snap.key
            }

            //print("Here is the returned userID:")
            //print(self.userID)
            self.getConversations(userID: self.userID, username: username)

            query.removeAllObservers()
        })
    }

    //Will get the conversationUID of all conversations a user participants in, when given user UID and username
    func getConversations(userID: String, username: String) {
        let query = Constants.Refs.databaseConvo.queryOrdered(byChild: userID).queryEqual(toValue: username)
        query.observe(.value, with: { (snapshot) in

            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                self.conversationIDs.append(snap.key)
                self.getMessagesInConvo(convoUID: snap.key)

                for children2 in snap.children {
                    let snap2 = children2 as! DataSnapshot
                    if (snap2.value as! String) != username {
                        self.otherParticipant[snap.key] = (snap2.value as! String)
                    }
                }
                //print(snap.key)
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

extension MessagesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationIDs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "threadCell", for: indexPath) as! MessagesTableViewCell
        let convoID = self.conversationIDs[indexPath.row]

        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "h:mm a"

        let myString =
            formatter.string(from: NSDate(timeIntervalSince1970: self.lastTimestampInEachConvo[convoID]!/1000) as Date)

        cell.convoID = convoID
        cell.nameLabel?.text = self.otherParticipant[convoID]
        cell.messageLabel?.text = self.lastMessageInEachConvo[convoID]
        cell.timeLabel?.text = myString
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")

        //let person = people[indexPath.row]

        //self.myVariable = person.value(forKeyPath: "username") as! String

        //self.performSegue(withIdentifier: "", sender: self)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(myVariable);
        if segue.identifier == "contactsToNewMessage" {
            //print(myVariable);

            //let destinationVC = segue.destination as? NewMessageViewController
            //destinationVC?.myVariable = self.myVariable
        }
    }

}
