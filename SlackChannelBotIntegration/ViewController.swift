//
//  ViewController.swift
//  SlackChannelBotIntegration
//
//  Created by Sierra 2 on 28/10/17.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import UIKit
import SwiftyJSON
import DropDown

class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var guestName: UITextField!
    @IBOutlet weak var responseView: UITextView!
    
    @IBOutlet weak var chooseReasonButton: UIButton!
    @IBOutlet weak var chooseHostButton: UIButton!
    
    var socketURL: String?
    var userName: String?
    var botID: String?
    var channelID: String?
    
    var guestname: String?
    var hostname: String?
    var reason: String?
    
    //MARK: - DropDown's
    
    let chooseHostDropDown = DropDown()
    let chooseReasonDropDown = DropDown()
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseHostDropDown,
            self.chooseReasonDropDown
        ]
    }()
    
    @IBAction func chooseArticle(_ sender: AnyObject) {
        chooseHostDropDown.show()
    }
    
    @IBAction func choose(_ sender: AnyObject) {
        chooseReasonDropDown.show()
    }
    @IBAction func sendGuestInfo(_ sender: UIButton) {
        
        var message = "Hey \(hostname)! \(guestName) is here for you at the front desk. Reason for visit: \(reason)"
        
        //SocketAPI.shared.sendMessage(id: 2323, type: "message", channelID: channelID ?? "", text: message ?? "")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SlackAPI.sharedInstance.rtm_start { (webSocketURl, botID) in
            self.socketURL = webSocketURl
            self.botID = botID
            SocketAPI.shared.connect(url: URL(string: webSocketURl)!)
            SocketAPI.shared.delegate = self
            SlackAPI.sharedInstance.getChannelList()
            self.setupChannel()
            self.setupDropDowns()
        }
        guestName.delegate = self

        photo.layer.borderWidth = 1
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guestName.resignFirstResponder()
    }
    
    //MARK: - Setup
    
    func setupDropDowns() {
        setupChooseHostDropDown()
        setupChooseReasonDropDown()
        setUpCustomizeDropDown(self)
    }
    
    func setupChooseReasonDropDown() {
        chooseReasonDropDown.anchorView = chooseReasonButton
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseReasonDropDown.bottomOffset = CGPoint(x: 0, y: chooseReasonButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseReasonDropDown.dataSource = [
            "Meeting",
            "Interview",
            "Vendor",
            "Friend or Family"
        ]
        
        // Action triggered on selection
        chooseReasonDropDown.selectionAction = { [weak self] (index, item) in
            self?.chooseReasonButton.setTitle(item, for: .normal)
            self?.reason = item
        }
    }
    
    func setupChooseHostDropDown() {
        chooseHostDropDown.anchorView = chooseHostButton
        
        // Will set a custom with instead of anchor view width
        //        dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseHostDropDown.bottomOffset = CGPoint(x: 0, y: chooseHostButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        
//        chooseHostDropDown.dataSource = host_names
        chooseHostDropDown.dataSource = [
            "Mandy Xiao (Bee)",
            "John Choi (JohnX)",
            "Ryan Lui (Rabbit)",
            "Gary Chung (sychung)"
        ]
        
        // Action triggered on selection
        chooseHostDropDown.selectionAction = { [weak self] (index, item) in
            self?.chooseHostButton.setTitle(item, for: .normal)
            self?.hostname = item
        }
        
        chooseHostDropDown.multiSelectionAction = { [weak self] (indices, items) in
            print("Muti selection action called with: \(items)")
            if items.isEmpty {
                self?.chooseHostButton.setTitle("", for: .normal)
            }
//            else
//            {
//                for host in host_names {
//                    self?.hostname?.append("\(host) ")
//                }
//
//                self?.chooseHostButton.setTitle("\(self?.hostname)", for: .normal)
//            }
        }
    }
    
    func setUpCustomizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        //        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
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
        guestname = textField.text ?? ""
        //SocketAPI.shared.sendMessage(id: 2323, type: "message", channelID: channelID ?? "", text: textField.text ?? "")
        return true
    }
}
//MARK:- Socket Delegate
extension ViewController: SocketDelegate {
    func message(_ messageDict: String) {
        let json = JSON.init(parseJSON: messageDict)
        print(json)
        //responseView.text = String(describing: json)
        print(messageDict)
        if let dict = convertToDictionary(text: messageDict) {
            if (dict["type"] ?? "") as? String == "message" {
                print(dict["text"] ?? "")
            }
        }
    }
}


