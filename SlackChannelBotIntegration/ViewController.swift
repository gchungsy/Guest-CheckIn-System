//
//  ViewController.swift
//  SlackChannelBotIntegration
//
//  Created by Sierra 2 on 28/10/17.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var responseView: UITextView!
    
    var socketURL: String?
    var userName: String?
    var botID: String?
    var channelID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SlackAPI.sharedInstance.rtm_start { (webSocketURl, botID) in
            self.socketURL = webSocketURl
            self.botID = botID
            SocketAPI.shared.connect(url: URL(string: webSocketURl)!)
            SocketAPI.shared.delegate = self
//            SlackAPI.sharedInstance.getChannelList()
            self.setupChannel()
        }
        textField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
    }
}
extension ViewController {
    func setupChannel() {
        if let channelID = UserDefaults.standard.value(forKey: "ChannelID") {
            self.channelID = channelID as? String
            self.inviteBotToChannel()
        }
        else {
            let channel_name = getRandomChannelName();
            SlackAPI.sharedInstance.channels_join(channel_name: channel_name) {
                (channelID: String) -> Void in
                UserDefaults.standard.setValue(channelID, forKey: "ChannelID");
                self.channelID = channelID;
                self.inviteBotToChannel();
            }
        }
    }
    
    func inviteBotToChannel() {
        if(self.channelID == nil || self.botID == nil) {
            return
        }
        SlackAPI.sharedInstance.channels_invite(channelID: channelID ?? "", userID: self.botID ?? "", completion: nil);
    }
    
    func getRandomChannelName() -> String {
        let prefix = self.randomString(length: 4)
        let username = Slack.misc.usernames[Int(arc4random()) % Int(Slack.misc.usernames.count)];
        return "\(prefix)-\(username)";
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        SocketAPI.shared.sendMessage(id: 2323, type: "message", channelID: channelID ?? "", text: textField.text ?? "")
        return true
    }
}
//MARK:- Socket Delegate
extension ViewController: SocketDelegate {
    func message(_ messageDict: String) {
        let json = JSON.init(parseJSON: messageDict)
        print(json)
        responseView.text = String(describing: json)
        print(messageDict)
        if let dict = convertToDictionary(text: messageDict) {
            if (dict["type"] ?? "") as? String == "message" {
                print(dict["text"] ?? "")
            }
        }
    }
}


