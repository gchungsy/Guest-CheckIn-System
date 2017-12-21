//
//  SlackAPI.swift
//  SlackChannelBotIntegration
//
//  Created by Sierra 2 on 30/10/17.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SlackAPI: NSObject {
    /// Singleton instance of `RSSlackAPI`
    static let sharedInstance = SlackAPI();
    
    /**
     Send "rtm_start" HTTPS API request to Slack. Returns info about users, channels, and the websocket RTM URL.
     This method also searches the user data for the ID of the user bot `Slack.misc.bot_name`, and stores all relevant user
     data (ID, profile, color and image URL). Finally, it calls the `completion` closure when the request is finished. It's recommended
     you connect to the websocket, because it closes in 30 seconds after "rtm_start".
     
     :param: completion Closure that's called upon completion of this method.
     */
    func rtm_start(completion: @escaping (String, String) -> Void)
    {
        var botID: String?
        Alamofire.request(Slack.URL.rtm.start, method: .get, parameters: [Slack.param.token: Slack.token.bot] as [String : Any], encoding: URLEncoding.default).responseJSON {
            response in
            
            if response.error != nil
            {
                print(response.error?.localizedDescription ?? "");
                return;
            }
            
            let json = JSON(response.data ?? Data());
            
            print(json);
            
            if let users = json[Slack.param.users].array
            {
                for user in users
                {
                    // Figure out user ID of bot
                    if user[Slack.param.name].string != nil && user[Slack.param.name].stringValue == Slack.misc.bot_name
                    {
                        botID = user[Slack.param.id].string ?? ""
                        print("BotID: ", user[Slack.param.id].string ?? "")
                    }
                    
                    // Store user data in RSMessageCenterAPI for later reference
                    var user_data = [String: AnyObject]();
                    
                    if  let id = user[Slack.param.id].string,
                        let profile = user[Slack.param.profile].dictionary,
                        let color = user[Slack.param.color].string,
                        let image = profile[Slack.param.image_32]?.string
                    {
                        user_data[Slack.param.color] = color as AnyObject;
                        user_data[Slack.param.image] = image as AnyObject;
                        print("UserData: ", user_data)
                    }
                }
            }
            
            // Get websocket URL and call completion closure
            if let url = json[Slack.param.url].string
            {
                completion(url, botID ?? "");
            }
            
        }
    }
    
    /**
     Send "channels_join" HTTPS API request to Slack. Uses the admin token (i.e. the admin user) to
     join a new channel with `channel_name`. To Slack, joining a channel creates a channel when it doesn't exist yet.
     The `completion` closure is executed when the request finishes, if the returned data is OK.
     
     :param: channel_name String with the name of the channel.
     :param: completion Closure with `channelID` parameter.
     */
    func channels_join(channel_name:String, completion: @escaping (_ channelID: String) -> Void)
    {
        Alamofire.request(Slack.URL.channels.join, method: .get ,parameters: [Slack.param.token: Slack.token.admin, Slack.param.name: channel_name]).responseJSON { response in
            if response.error != nil
            {
                print(response.error?.localizedDescription ?? "");
                return;
            }
            
            let json = JSON(response.data!);
            print(json)
            if  let channel = json[Slack.param.channel].dictionary,
                let channelID = channel[Slack.param.id]?.string
            {
                completion(channelID);
            }
        }
    }
    
    /**
     Send "channels_invite" HTTPS API request to Slack. Used to invite a user with `userID` to channel with `channelID`. Calls a closure upon completion.
     In the example project, this is used to invite the bot user to the new message center channel. The admin user is already invited, because it created/joined the channel.
     
     :param: channelID The channel to invite to.
     :param: userID The user ID of the user to invite to the channel.
     :param: completion Optional closure to be called when the request finishes.
     */
    
    func getChannelList() {
        Alamofire.request(Slack.URL.channels.channelList, method: .get, parameters: [Slack.param.token : Slack.token.admin], encoding: URLEncoding.default).responseJSON { (response) in
            if response.error != nil
            {
                print(response.error?.localizedDescription ?? "");
                return;
            }
            let json = JSON(response.data ?? Data());
            
            print(json);
        }
    }
    
    func channels_invite(channelID:String, userID:String, completion: (() -> Void)?)
    {
        Alamofire.request(Slack.URL.channels.invite, method: .get, parameters: [Slack.param.token: Slack.token.admin, Slack.param.channel: channelID, Slack.param.user: userID]).responseJSON { response in
            
            if response.error != nil
            {
                print(response.error?.localizedDescription ?? "");
                return;
            }
            
            let json = JSON(response.data ?? Data());
            
            print(json);
            
            if(completion != nil)
            {
                completion!();
            }
        }
    }
}
