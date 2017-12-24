//
//  ViewController.swift
//  SlackChannelBotIntegration
//
//  Created by Gary Chung on 20/12/17.

import UIKit
import SwiftyJSON
import DropDown
import SKWebAPI
import RSSelectionMenu

class ViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var guestField: TextFieldEffects!
    @IBOutlet weak var reasonField: IsaoTextField!
    @IBOutlet weak var hostField: IsaoTextField!
    
    @IBOutlet weak var chooseReasonButton: UIButton!
    @IBOutlet weak var chooseHostButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var socketURL: String?
    var userName: String?
    var botID: String?
    var channelID: String?
    
    let simpleDataArray = ["Sachin", "Rahul", "Saurav", "Virat", "Suresh", "Ravindra", "Chris", "Steve", "Anil"]
    var simpleSelectedArray = [String]()
    
    let dataArray = ["Sachin Tendulkar", "Rahul Dravid", "Saurav Ganguli", "Virat Kohli", "Suresh Raina", "Ravindra Jadeja", "Chris Gyle", "Steve Smith", "Anil Kumble"]
    var selectedDataArray = [String]()
    
    //MARK: - DropDown's

    let chooseReasonDropDown = DropDown()
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseReasonDropDown
        ]
    }()
    
    @IBAction func chooseArticle(_ sender: AnyObject) {
        showAsFormSheetWithSearch()
    }
    
    @IBAction func choose(_ sender: AnyObject) {
        chooseReasonDropDown.show()
    }
    
    @IBAction func didTapSubmitButton(_ sender: UIButton) {
        
        let webAPI = WebAPI(token: "xoxp-289779861170-289260365345-290797256836-10ef463e6958e8c9cf4785b2ab79668b")
        webAPI.authenticationTest(success: { (success) in
            print("-----------------------------------------------------")
            print(success)
            
            webAPI.usersList(success: { (users) in
                
                for user in users!
                {
                    if user[Slack.param.name] as! String != Slack.misc.bot_name && user[Slack.param.name] as! String != Slack.misc.slack_bot_name
                    {
                        
                        print("-----------------------------------------------------")
                        
                        var name = user[Slack.param.name] as! String
                        var realname = user[Slack.param.realname] as! String
                        var id = user[Slack.param.id] as! String
                        
                        print("User_Name: ", name)
                        print("User_RealName: ", realname)
                        print("User_ID: ", id)
                        
                        arrayOfUsers.append(User(Name: name, RealName: realname, ID: id))
                        
                    }
   
                    
                }
                
                webAPI.sendMessage(channel: "U8H7NARA5", text: "Hi Me", success: { (ts, channel) in
                    print(ts)
                    print(channel)
                }, failure: { (error) in
                    print(error)
                })
                
                
                webAPI.sendMessage(channel: "U8KUWT31D", text: "Hi invincible", success: { (ts, channel) in
                    print(ts)
                    print(channel)
                }, failure: { (error) in
                    print(error)
                })
                
            }, failure: { (error) in
                print(error)
            })
            
            
            var webhookbot = Slackbot(url: "https://hooks.slack.com/services/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")
            
            webhookbot.botname = "information_desk"
            webhookbot.icon = ":information_desk_person:" //https://www.webpagefx.com/tools/emoji-cheat-sheet/
            webhookbot.channel = "U8KUWT31D"
            webhookbot.markdown = true
            
            let pretext = "*Hey Simon! Gary is here for you at the front desk.*"
            
            let fields = [slackFields(title: "Full Name",
                                      value: "This text\nis in the left column",
                                      short: true),
                          slackFields(title: "Reason For Visit",
                                      value: "But this text\nis in the right column",
                                      short: true)]
            
            webhookbot.sendSideBySideMessage(fallback: "New Side by Side Message", pretext: pretext, fields: fields)
            
        }, failure: nil)
        
        
    }
    
    func clearUserFields() {
        
        guard let text = guestField.text, !text.isEmpty else {
            return // return false, already empty
        }
        guestField.text = ""
        
        //examine the size of the image if find out if user have uploaded their own photo
        //sizeOfUIImage()
        //if chooseReasonButton.Title(for: .normal) == "" { }
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
    
    func showAsPopover(_ sender: UIView) {
        
        // Show as Popover with datasource
        let selectionMenu = RSSelectionMenu(dataSource: simpleDataArray) { (cell, object, indexPath) in
            cell.textLabel?.text = object
        }
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.simpleSelectedArray = selectedItems
        }
        
        // show as popover
        // Here specify popover sourceView and size of popover
        // specifying nil will present with default size
        selectionMenu.show(style: .Popover(sourceView: sender, size: nil), from: self)
    }
    
    func showAsFormSheetWithSearch() {
        
        // Show menu with datasource array - PresentationStyle = Formsheet & SearchBar
        let selectionMenu = RSSelectionMenu(dataSource: dataArray) { (cell, object, indexPath) in
            cell.textLabel?.text = object
        }
        
        // show selected items
        selectionMenu.setSelectedItems(items: selectedDataArray) { (text, selected, selectedItems) in
            self.selectedDataArray = selectedItems
        }
        
        // show searchbar with placeholder text and barTintColor
        // Here you'll get search text - when user types in seachbar
        selectionMenu.showSearchBar(withPlaceHolder: "Search Player", tintColor: UIColor.white.withAlphaComponent(0.3)) { (searchText) -> ([String]) in
            
            // return filtered array based on any condition
            // here let's return array where firstname starts with specified search text
            return self.dataArray.filter({ $0.lowercased().hasPrefix(searchText.lowercased()) })
        }
        
        // show as formsheet
        selectionMenu.show(style: .Formsheet, from: self)
    }
    
    func setupDropDowns() {
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

  // MARK: - Image Picker
  @IBAction func didTapTakePicture(_: AnyObject) {
    let picker = UIImagePickerController()
    picker.delegate = self
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      picker.sourceType = .camera
    } else {
      picker.sourceType = .photoLibrary
    }

    present(picker, animated: true, completion:nil)
  }

  func imagePickerController(_ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [String : Any]) {
      picker.dismiss(animated: true, completion:nil)

    urlTextView.text = "Beginning Upload"
    // if it's a photo from the library, not an image from the camera
    if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
      let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl], options: nil)
      let asset = assets.firstObject
      asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
        let imageFile = contentEditingInput?.fullSizeImageURL
        let filePath = Auth.auth().currentUser!.uid +
          "/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(imageFile!.lastPathComponent)"
        // [START uploadimage]
        self.storageRef.child(filePath)
          .putFile(from: imageFile!, metadata: nil) { (metadata, error) in
            if let error = error {
              print("Error uploading: \(error)")
              self.urlTextView.text = "Upload Failed"
              return
            }
            self.uploadSuccess(metadata!, storagePath: filePath)
        }
        // [END uploadimage]
      })
    } else {
      guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
      guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return }
      let imagePath = Auth.auth().currentUser!.uid +
        "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
      let metadata = StorageMetadata()
      metadata.contentType = "image/jpeg"
      self.storageRef.child(imagePath).putData(imageData, metadata: metadata) { (metadata, error) in
        if let error = error {
          print("Error uploading: \(error)")
          self.urlTextView.text = "Upload Failed"
          return
        }
        self.uploadSuccess(metadata!, storagePath: imagePath)
      }
    }
  }

  func uploadSuccess(_ metadata: StorageMetadata, storagePath: String) {
    print("Upload Succeeded!")
    self.urlTextView.text = metadata.downloadURL()?.absoluteString
    UserDefaults.standard.set(storagePath, forKey: "storagePath")
    UserDefaults.standard.synchronize()
    self.downloadPicButton.isEnabled = true
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion:nil)
}

