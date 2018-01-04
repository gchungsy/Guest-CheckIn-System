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
    
    func fetchImage(asset: PHAsset, completion: @escaping  (UIImage) -> ()) {
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImageData(for: asset, options: options) {
            data, uti, orientation, info in
            guard let data = data, let image = UIImage(data: data) else { return }
            self.photo.contentMode = .scaleAspectFit
            self.photo.image = image
            print("image size:", image.size)
            completion(image)
        }
    }
    
    // MARK: - Image Picker
    func didTapTakePicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.allowsEditing = false
        } else {
            photo.image = #imageLiteral(resourceName: "media-20171223")
            imageData = UIImagePNGRepresentation(#imageLiteral(resourceName: "media-20171223")) as Data?
            photoField.text = "Done!"
            return
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion:nil)
        
        // if it's a photo from the library, not an image from the camera
        if #available(iOS 8.0, *), let referenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            let asset = PHAsset.fetchAssets(withALAssetURLs: [referenceUrl], options: PHFetchOptions()).firstObject
            fetchImage(asset: asset!) {
                self.photo.image = $0
                imageData = UIImagePNGRepresentation($0) as Data?
            }
            
        } else {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            photo.image = image
            imageData = UIImagePNGRepresentation(image) as Data?
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}
