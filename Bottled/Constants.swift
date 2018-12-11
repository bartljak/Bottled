//
//  Constants.swift
//  Bottled
//
//  Created by Jake Bartles on 10/16/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import Foundation
import Firebase

struct Constants {
    struct Refs {
        static let databaseRoot = Database.database().reference()
        static let databaseConvo = databaseRoot.child("conversations")
        static var databaseUsers = databaseRoot.child("users")
        static let databaseMssgs = databaseRoot.child("messages")

        static let databaseChats = databaseRoot.child("chats")
    }
}
