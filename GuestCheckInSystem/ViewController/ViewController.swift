//
//  ViewController.swift
//  SlackChannelBotIntegration
//
//  Created by Gary Chung on 20/12/17.

import UIKit
//import SwiftyJSON
import DropDown
import RSSelectionMenu
import Photos
import SKWebAPI

var imageData: Data?

class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var guestField: IsaoTextField!
    @IBOutlet weak var reasonField: IsaoTextField!
    @IBOutlet weak var hostField: IsaoTextField!
    @IBOutlet weak var photoField: IsaoTextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var socketURL: String?
    var userName: String?
    var botID: String?
    var channelID: String?
    
    var user_array = [User]()
    var user_name_array = [String]()
    var user_realname_array = [String]()
    var user_firstname_array = [String]()
    var user_id_array = [String]()
    var user_dropdown_name_array = [String]()

    let simpleDataArray = ["Sachin", "Rahul", "Saurav", "Virat", "Suresh", "Ravindra", "Chris", "Steve", "Anil"]
    var simpleSelectedArray = [String]()
    
    let dataArray = ["Sachin Tendulkar", "Rahul Dravid", "Saurav Ganguli", "Virat Kohli", "Suresh Raina", "Ravindra Jadeja", "Chris Gyle", "Steve Smith", "Anil Kumble"]
    var selectedDataArray = [String]()
    
    var delegate: RSSelectionMenuDelegate<Any>?
    
    var webhookbot = Slackbot(url: SlackID.WebHookUrl.rawValue)
    let webAPI = WebAPI(token: SlackID.WebAPIToken.rawValue)
    
    //MARK: - DropDown's

    let chooseReasonDropDown = DropDown()
    
    lazy var dropDowns: [DropDown] = { return [self.chooseReasonDropDown] }()
    
    @IBAction func didTapSubmitButton(_ sender: UIButton) {
        
        var imageURL: String!
        var channels = [String]()
        let record_guest = guestField.text!
        let record_reason = reasonField.text!
        if clearUserFields() {
            
//            for user_realname in selectedDataArray {
//                if let i = user_array.index(where: {$0.realname == user_realname}) {
//                    let obj = user_array[i]
//                    channels.append(obj.id)
//                }
//            }
            
            channels.append("#general") // Send picture to '#general' public channel everytime so that we can get the image URL the be public (saves money but bad)
            if imageData != nil {
                webAPI.authenticationTest(success: { (success) in
                    self.webAPI.uploadFile(file: imageData!, filename: record_guest + ".png", channels: channels, success: { (file) in
                        print("-------------------------------------")
                        imageURL = file.urlPrivate!
                        print(imageURL)
                        print(file)
                        self.sendMessage(record_guest: record_guest, record_reason: record_reason, imageURL: imageURL!)
                    }, failure: { (error) in
                        self.sendMessage(record_guest: record_guest, record_reason: record_reason)
                        print(error)
                    })
                }, failure: nil)
            }
        }
        else
        {
            showMessagePrompt("Please complete the form before you submit it.")
        }
    }
    
    func sendMessage(record_guest:String, record_reason: String, imageURL: String? = nil) {
        
        for user_realname in selectedDataArray {
            if let i = user_array.index(where: {$0.realname == user_realname}) {
                let obj = user_array[i]
                webhookbot.botname = "visitbot"
                webhookbot.icon = ":runner:" //https://www.webpagefx.com/tools/emoji-cheat-sheet/
                webhookbot.markdown = true
                webhookbot.channel = obj.id
                let pretext = "*Hey \(obj.firstname)! \(record_guest.capitalized) is here for you at the front desk.*"
                let fields = [slackFields(title: "Reason For Visit",value: "\(record_reason)\n",short: true)]
                
                if imageURL != nil {
                    webhookbot.sendSideBySideMessage(fallback: "New Message", pretext: pretext, color: "#D00000", fields: fields, image: imageURL, thumb: imageURL)
                } else {
                    webhookbot.sendSideBySideMessage(fallback: "New Message", pretext: pretext, color: "#D00000", fields: fields)
                }
            }
        }
    }
    
    
    func fetchWorkSpaceUsers() {
        webAPI.authenticationTest(success: { (success) in
            self.webAPI.usersList(success: { (users) in
                print(users)
                for user in users!
                {
                    if user[Slack.param.name] as! String != Slack.misc.bot_name && user[Slack.param.name] as! String != Slack.misc.slack_bot_name
                    {
                        var name = user[Slack.param.name] as! String
                        var realname = user[Slack.param.realname] as! String
                        var id = user[Slack.param.id] as! String
                        
                        var firstname = ""
                        var components = realname.components(separatedBy: " ")
                        if(components.count > 0) {
                            firstname = components.removeFirst()
                        }
                        print("User_Name: ", name)
                        print("User_RealName: ", realname)
                        print("User_FirstName: ", firstname)
                        print("User_ID: ", id)
                        
                        self.user_array.append(User(Name: name, RealName: realname, FirstName: firstname, ID: id))
                        //self.user_name_array.append(name)
                        self.user_realname_array.append(realname)
                        //self.user_id_array.append(id)
                    }
                }
            }, failure: { (error) in
                print(error)
            })
        }, failure: nil)
    }
    
    func clearUserFields()-> Bool{
        
        guard let guest_text = guestField.text, !guest_text.isEmpty else { return false }
        guard let reason_text = reasonField.text, !reason_text.isEmpty else { return false }
        guard let host_text = hostField.text, !host_text.isEmpty else { return false }
        
        showMessagePrompt("Please have a seat.   \n Your host will be right with you.")
        guestField.text = ""
        reasonField.text = ""
        hostField.text = ""
        photoField.text = ""
        photo.image = #imageLiteral(resourceName: "maximus_preview1-")
        //examine the size of the image if find out if user have uploaded their own photo
        //sizeOfUIImage()
        
        return true
    }
    
    func sizeOfUIImage() {
      if let data = UIImagePNGRepresentation(#imageLiteral(resourceName: "VanGogh.jpg")) as Data? {
      print("There were \(data.count) bytes")
      let bcf = ByteCountFormatter()
      bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
      bcf.countStyle = .file
      let string = bcf.string(fromByteCount: Int64(data.count))
      print("formatted result: \(string)")
      }
    }
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchWorkSpaceUsers()
        setupDropDowns()
        
        // ImageView
        photo.layer.borderWidth = 1
        photo.layer.borderColor = UIColor.clear.cgColor
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        photo.image = #imageLiteral(resourceName: "maximus_preview1-")
        
        // TextField
        guestField.clearsOnBeginEditing = true
        hostField.isUserInteractionEnabled = false
        reasonField.isUserInteractionEnabled = false
        photoField.isUserInteractionEnabled = false
        
        // Button
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor.lightGray.cgColor
        submitButton.layer.masksToBounds = false
        submitButton.layer.cornerRadius = 30
        submitButton.clipsToBounds = true
        
        submitButton.addTarget(self, action: #selector(changeDownButton), for: .touchDown)
        submitButton.addTarget(self, action: #selector(changeUpButton), for: .touchUpInside)
        
        // Add guesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didRecognizeTapReasonField(_:)))
        reasonField.superview?.addGestureRecognizer(tapGesture)
        hostField.superview?.addGestureRecognizer(tapGesture)
        photoField.superview?.addGestureRecognizer(tapGesture)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guestField.resignFirstResponder()
    }
    
    func changeDownButton(sender: UIButton) {
        sender.layer.borderColor = UIColor.myLightGrey.cgColor
    }
    
    func changeUpButton(sender: UIButton) {
        sender.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private dynamic func didRecognizeTapReasonField(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        if gesture.state == .ended {
            if reasonField.frame.contains(point) {
                chooseReasonDropDown.show()
            }
            if photoField.frame.contains(point) {
                didTapTakePicture()
            }
            if hostField.frame.contains(point) {
                showAsFormSheetWithSearch()
            }
        }
    }
    
    //MARK: - Setup
    
    func showAsFormSheetWithSearch() {
        
        // Single Selection List
//        let selectionMenu = RSSelectionMenu(dataSource: user_realname_array) { (cell, object, indexPath) in
//            cell.textLabel?.text = object
//        }
        
        // Multiple Selection List
        let selectionMenu = RSSelectionMenu(selectionType: .Multiple, dataSource: user_realname_array, cellType: .Basic) { (cell, object, indexPath) in
            cell.textLabel?.text = object
        }
        selectionMenu.reloadInputViews()
        // show selected items
        selectionMenu.setSelectedItems(items: selectedDataArray) { (text, selected, selectedItems) in
            
            var localArray = [String]()
            
            for user_realname in selectedItems {
                if let i = self.user_array.index(where: {$0.realname == user_realname}) {
                    let obj = self.user_array[i]
                    localArray.append("\(obj.firstname)")
                }
            }
            self.hostField.text = localArray.joined(separator: ", ")
            self.selectedDataArray = selectedItems
        }
        
        // show searchbar with placeholder text and barTintColor
        // Here you'll get search text - when user types in seachbar
        selectionMenu.showSearchBar(withPlaceHolder: "Search Player", tintColor: UIColor.white.withAlphaComponent(0.3)) { (searchText) -> ([String]) in
            
            // return filtered array based on any condition
            // here let's return array where firstname starts with specified search text
            return self.user_realname_array.filter({ $0.lowercased().hasPrefix(searchText.lowercased()) })
        }
        
        // show as formsheet
        selectionMenu.show(style: .Formsheet, from: self)
    }
    
    func setupDropDowns() {
        setupChooseReasonDropDown()
        setUpCustomizeDropDown(self)
    }
    
    func setupChooseReasonDropDown() {
        chooseReasonDropDown.anchorView = reasonField
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseReasonDropDown.bottomOffset = CGPoint(x: 0, y: reasonField.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseReasonDropDown.dataSource = Slack.misc.reasons_to_visit
        
        // Action triggered on selection
        chooseReasonDropDown.selectionAction = { [weak self] (index, item) in
            //self?.chooseReasonButton.setTitle(item, for: .normal)
            self?.reasonField.text = item
        }
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

