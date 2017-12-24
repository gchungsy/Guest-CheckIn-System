//
//  User.swift
//  SlackChannelBotIntegration
//
//  Created by sychung on 2017-12-21.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import Foundation
import UIKit

var arrayOfUsers = [User]()

class Company {
    var logo : UIImage? // Slackbot icon
    var slack_channels : [String]
    var user_list : [User]
    var host_names = [String]()
    
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
    
    func getSlackChannels()->[String] {
        return slack_channels
    }
    
    func getUserList()->[User] {
        return user_list
    }
    
    func getHostNames()->[String] {
        return host_names
    }
    
}

class User {
    var name: String
    var realname: String
    var id: String
    
    init(Name:String, RealName:String, ID:String) {
        name = Name
        realname = RealName
        id = ID
    }
}
