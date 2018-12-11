//
//  ViewController.swift
//  Bottled
//
//  Created by Jake Bartles on 10/16/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {

    var userUID: String = ""
    var username: String = ""
    
    var convoUID: String = ""
    
    var recipUser: String = ""
    var recipUID: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    var messages = [JSQMessage]()

    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationController?.isNavigationBarHidden = false
    }

    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    override func viewDidLoad() {

        super.viewDidLoad()

        // temporary constant for the standard UserDefaults
        let defaults = UserDefaults.standard
        // check if message has id and name
        username = defaults.string(forKey: "Username")!
        userUID = defaults.string(forKey: "UserUID")!
        convoUID = defaults.string(forKey: "selectedconvo")!
        
        senderId = username
        senderDisplayName = username
        
        // display sender name at the top of screen
        title = "Chat Window"

        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        print("convo uid is:", convoUID)
        Constants.Refs.databaseConvo.child(convoUID).observeSingleEvent(of: .value, with: { (snapshot) in
            for childsnap in snapshot.children {
                let child = childsnap as! DataSnapshot
                let receipname = child.value as! String
                if(receipname != self.username)
                {
                    self.recipUID = child.key
                    self.recipUser = receipname
                    self.title = "Chat: " + self.recipUser
                }
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.continueListening()
        
        /*
        let query = Constants.Refs.databaseMssgs.queryOrdered(byChild: "convo").queryEqual(toValue: convoUID)
        query.observeSingleEvent(of: .value, with: { (snapshot) in
            for childSnapshot in snapshot.children {
                let snap = childSnapshot as! DataSnapshot
                
                let tempSender = snap.childSnapshot(forPath: "sender").value as! String
                let tempPayload = snap.childSnapshot(forPath: "payload").value as! String
                
                if let message = JSQMessage(senderId: tempSender, displayName: tempSender, text: tempPayload) {
                    self.messages.append(message)
                }
            }
            
            self.finishReceivingMessage()
            self.continueListening()
            
        }) { (error) in
            print(error.localizedDescription)
        }*/
    }
    
    func continueListening()
    {
        let query2 = Constants.Refs.databaseMssgs.queryOrdered(byChild: "convo").queryEqual(toValue: convoUID)
        // add observer to our query
        _ = query2.observe(.childAdded, with: { [weak self] snapshot in
            // unpack data
            
            let tempSender  = snapshot.childSnapshot(forPath: "sender").value as! String
            let tempPayload = snapshot.childSnapshot(forPath: "payload").value as! String
            
            if let message = JSQMessage(senderId: tempSender, displayName: tempSender, text: tempPayload) {
                self?.messages.append(message)
                self?.finishReceivingMessage()
            }
            
        })
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    // delegate to control which bubble is displayed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }

    // hides avatars
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }

    // called when label text is needed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }

    // called when the height of the top label is needed
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }

   // override, user hits send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        // get chats from firebase
        let key = Constants.Refs.databaseMssgs.childByAutoId().key
        //let post = [key: users[i]]
        let childUpdates = [key: ["convo": self.convoUID,
                                  "payload": text,
                                  "sender": self.username,
                                  "timestamp": [".sv": "timestamp"]
            ]
        ]
        Constants.Refs.databaseMssgs.updateChildValues(childUpdates)

        finishSendingMessage()
    }
}
