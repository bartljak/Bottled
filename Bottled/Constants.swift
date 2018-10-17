//
//  Constants.swift
//  Bottled
//
//  Created by Jake Bartles on 10/16/18.
//  Copyright © 2018 PSV. All rights reserved.
//

import Foundation
import Firebase


struct Constants
{
    struct refs
    {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
    }
}
