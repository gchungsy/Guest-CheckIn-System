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
import SKWebAPI
import RSSelectionMenu

class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var guestField: TextFieldEffects!
    @IBOutlet weak var responseView: UITextView!
    @IBOutlet weak var reasonField: IsaoTextField!
    
    @IBOutlet weak var hostField: IsaoTextField!
    @IBOutlet weak var chooseReasonButton: UIButton!
    @IBOutlet weak var chooseHostButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    var socketURL: String?
    var userName: String?
    var botID: String?
    var channelID: String?
    
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
    
    @IBAction func didTapSubmitButton(_ sender: UIButton) {
        
    }
    
    //MARK: - LifeCycle
    
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
        

        // ImageView
        photo.layer.borderWidth = 1
        photo.layer.borderColor = UIColor.clear.cgColor
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        // TextField
        //guestName.delegate = self
        //guestName.setPadding()
        //guestName.setBottomBorder()
        //guestName.font = UIFont(name: "Helvetica", size: 14)!
        
        hostField.isUserInteractionEnabled = false
        reasonField.isUserInteractionEnabled = false
        
        // Button
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.lightGray.cgColor
        submitButton.layer.masksToBounds = false
        submitButton.layer.cornerRadius = 30
        submitButton.clipsToBounds = true
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guestField.resignFirstResponder()
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
        }
        
        chooseHostDropDown.multiSelectionAction = { [weak self] (indices, items) in
            print("Muti selection action called with: \(items)")
            if items.isEmpty {
                self?.chooseHostButton.setTitle("", for: .normal)
            }
//            else
//            {
//                self?.chooseHostButton.setTitle("\(items)", for: .normal)
//            }
        }
        
        // Action triggered on dropdown cancelation (hide)
        //        dropDown.cancelAction = { [unowned self] in
        //            // You could for example deselect the selected item
        //            self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //            self.actionButton.setTitle("Canceled", forState: .Normal)
        //        }
        
        // You can manually select a row if needed
        //        dropDown.selectRowAtIndex(3)
    }
    
    func setUpCustomizeDropDown(_ sender: AnyObject) {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 40
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        //        appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 10
        //appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        //appearance.shadowOpacity = 0.9
        //appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        appearance.textFont = UIFont(name: "Helvetica", size: 14)!
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
        //responseView.text = String(describing: json)
        print(messageDict)
        if let dict = convertToDictionary(text: messageDict) {
            if (dict["type"] ?? "") as? String == "message" {
                print(dict["text"] ?? "")
            }
        }
    }
}

//
//extension UITextField {
//
//    func setPadding() {
//        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: self.frame.height))
//        self.leftView = paddingView
//        self.leftViewMode = .always
//    }
//
//    func setBottomBorder() {
//        self.layer.shadowColor = UIColor.darkGray.cgColor
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowRadius = 0.0
//    }
//}
//
////extension UILabel {
////
////    func setBottomBorder() {
////        self.layer.shadowColor = UIColor.darkGray.cgColor
////        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
////        self.layer.shadowOpacity = 1.0
////        self.layer.shadowRadius = 0.0
////    }
////}

