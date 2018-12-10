//
//  ViewController.swift
//  Bottled
//
//  Created by Jake Bartles on 10/16/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
        if  let jsq_id = defaults.string(forKey: "jsq_id"),
            let name = defaults.string(forKey: "jsq_name") {
            senderId = jsq_id
            senderDisplayName = name
        }
        // user doesnt exist
        else {
            // assign random ID to senderid and make name empty
            senderId = String(arc4random_uniform(999999))
            senderDisplayName = ""
            // save ID in user defaults
            defaults.set(senderId, forKey: "jsq_id")
            defaults.synchronize()
            // display alert
            showDisplayNameDialog()
        }
        // display sender name at the top of screen
        title = "Chat: \(senderDisplayName!)"

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showDisplayNameDialog))
        tapGesture.numberOfTapsRequired = 1

        navigationController?.navigationBar.addGestureRecognizer(tapGesture)

        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero

        // create query to get last 10 chat messages
        let query = Constants.Refs.databaseChats.queryLimited(toLast: 10)
        // add observer to our query
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            // unpack data
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
                !text.isEmpty {
                // create JSQMessage object
                if let message = JSQMessage(senderId: id, displayName: name, text: text) {
                    self?.messages.append(message)

                    self?.finishReceivingMessage()
                }
            }
        })
    }

    @objc func showDisplayNameDialog() {
        let defaults = UserDefaults.standard
        // create alert controller
        let alert = UIAlertController(title: "Your Display Name", message: "Before you can chat, please choose a display name. Others will see this name when you send chat messages. You can change your display name again by tapping the navigation bar.", preferredStyle: .alert)

        alert.addTextField { textField in

            if let name = defaults.string(forKey: "jsq_name") {
                textField.text = name
            } else {
                let names = ["Ford", "Arthur", "Zaphod", "Trillian", "Slartibartfast", "Humma Kavula", "Deep Thought"]
                textField.text = names[Int(arc4random_uniform(UInt32(names.count)))]
            }
        }

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak alert] _ in

            if let textField = alert?.textFields?[0], !textField.text!.isEmpty {

                self?.senderDisplayName = textField.text

                self?.title = "Chat: \(self!.senderDisplayName!)"

                defaults.set(textField.text, forKey: "jsq_name")
                defaults.synchronize()
            }
        }))

        present(alert, animated: true, completion: nil)
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
        let ref = Constants.Refs.databaseChats.childByAutoId()

        // dictionary of things to be sent
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]

        ref.setValue(message)

        finishSendingMessage()
    }
}
