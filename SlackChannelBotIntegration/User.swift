//
//  User.swift
//  SlackChannelBotIntegration
//
//  Created by sychung on 2017-12-21.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import Foundation
import UIKit

class Company {
    var logo : UIImage? // Slackbot icon
    var slack_channels : [String]
    var user_list : [User]
    
    init() {
        slack_channels = [String]() //Empty
        user_list = [User]() // Empty
    }
    
    func addUser(newUser: User) {
        user_list.append(newUser)
    }
    
    func addChannel(newChannel: String) {
        slack_channels.append(newChannel)
    }
    
    func changeImage(Image: UIImage) {
        logo = Image
    }
    
}

class User {
    var name: String
    var realname: String
    var email: String
    
    init(Name:String, RealName:String, Email:String) {
        name = Name
        realname = RealName
        email = Email
    }
}
