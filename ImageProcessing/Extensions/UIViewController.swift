//
//  UIViewController.swift
//  ImageProcessing
//
//  Created by Tarek on 12/7/20.
//

import UIKit
import Photos
extension UIViewController {
    
    func showAlert(_ msg:String) {
        let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    func savePhotoToLibrary(withData data: Data, completion:@escaping (_ Success: Bool) -> ()) {
         var status = PHPhotoLibrary.authorizationStatus()
         switch status {
         case .authorized:()
         case .denied, .restricted :()
         case .notDetermined:
             PHPhotoLibrary.requestAuthorization { newStatus in
                 switch newStatus {
                 case .authorized: status = newStatus
                 case .denied, .restricted:()
                 case .notDetermined:()
                 @unknown default:()
                 }
             }
         @unknown default:()
         }
        
        if status == .authorized {
             PHPhotoLibrary.shared().performChanges({
                 let request = PHAssetCreationRequest.forAsset()
                 request.addResource(with: PHAssetResourceType.photo, data: data, options: nil)
                 request.creationDate = Date()
                completion(true)
             })
         }
     }
}
