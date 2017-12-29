//
//  ImageUploadManager.swift
//  SlackChannelBotIntegration
//
//  Created by sychung on 2017-12-24.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
        //urlTextView.text = "Beginning Upload"
        // if it's a photo from the library, not an image from the camera
        if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            let assets = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl], options: nil)
            let asset = assets.firstObject
            //      asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
            //        let imageFile = contentEditingInput?.fullSizeImageURL
            //        //let filePath = Auth.auth().currentUser!.uid +
            //          "/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(imageFile!.lastPathComponent)"
            //        // [START uploadimage]
            //        self.storageRef.child(filePath)
            //          .putFile(from: imageFile!, metadata: nil) { (metadata, error) in
            //            if let error = error {
            //              print("Error uploading: \(error)")
            //              self.urlTextView.text = "Upload Failed"
            //              return
            //            }
            //            self.uploadSuccess(metadata!, storagePath: filePath)
            //        }
            //        // [END uploadimage]
            //      })
        } else {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else { return }
            //let imagePath = Auth.auth().currentUser!.uid +
            "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            //let metadata = StorageMetadata()
            //metadata.contentType = "image/jpeg"
            //      self.storageRef.child(imagePath).putData(imageData, metadata: metadata) { (metadata, error) in
            //        if let error = error {
            //          print("Error uploading: \(error)")
            //          self.urlTextView.text = "Upload Failed"
            //          return
            //        }
            //        self.uploadSuccess(metadata!, storagePath: imagePath)
            //      }
        }
    }
    
    func uploadSuccess(storagePath: String) {
        print("Upload Succeeded!")
        //self.urlTextView.text = metadata.downloadURL()?.absoluteString
        UserDefaults.standard.set(storagePath, forKey: "storagePath")
        UserDefaults.standard.synchronize()
        //self.submitButton.isEnabled = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
