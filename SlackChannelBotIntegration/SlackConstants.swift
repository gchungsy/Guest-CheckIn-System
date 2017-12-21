//
//  SlackConstants.swift
//  SlackChannelBotIntegration
//
//  Created by Sierra 2 on 28/10/17.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import Foundation

enum SlackID: String {
    case botUser = "dummy-bot"
    case botToken = "xoxb-SLACK_GENERATED_ID"
    
    case slackExampleClientID = "SLACK_GENERATED_ID"
    case slackExampleSecret = "SLACK_GENERATED_SECRET"
    case slackExampleVerificationToken = "SLACK_GENERATED_VERIFICATION_TOKEN"
    case slackExampleID = "xoxp-SLACK_GENERATED_ID"
}

struct Slack {
    /// Slack HTTPS API URLs
    struct URL {
        struct rtm {
            static let start = "https://slack.com/api/rtm.start";
        }
        
        struct channels {
            static let create = "https://slack.com/api/channels.create";
            static let join = "https://slack.com/api/channels.join";
            static let invite = "https://slack.com/api/channels.invite";
            static let channelList = "https://slack.com/api/channels.list"
        }
    }
    /// Parameter constants as found in Slack data
    struct param {
        static let token = "token";
        static let ok = "ok";
        static let url = "url";
        static let channels = "channels";
        static let name = "name";
        static let channel = "channel";
        static let id = "id";
        static let type = "type";
        static let text = "text";
        static let users = "users";
        static let user = "user";
        static let profile = "profile";
        static let image_32 = "image_32";
        static let color = "color";
        static let connect = "connect"
        
        static let image = "image";
        static let image_data = "image_data";
    }
    // Message types as found in Slack data
    struct type {
        static let message = "message";
        static let user_typing = "user_typing";
    }
    // User tokens for the Slack bot and user. Note: storing these in a production app is very unsafe and not secure !!!
    struct token {
        static let bot = SlackID.botToken.rawValue
        static let admin = SlackID.slackExampleID.rawValue
    }
    // Misc. constants, the username of the Slack bot, and don't forget your towel.
    struct misc {
        static let usernames = ["arthur", "ford", "trillian", "zaphod", "marvin", "eddie", "hamma-kavula", "slartibartfast", "deep-thought", "agrajag", "vogon-jeltz"];
        static let bot_name = SlackID.botUser.rawValue
    }
}

struct MessageCenter {
    // Dictionary keys for NSUserDefaults
    struct prefs {
        static let channelID = "channel_id";
    }
    // Notification types as used in the Message Center
    struct notification {
        static let newMessage = "new_message";
        static let userTyping = "user_typing";
    }
}
