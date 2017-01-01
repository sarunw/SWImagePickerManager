//
//  SWImagePickerManager.swift
//  Pods
//
//  Created by Sarun Wongpatcharapakorn on 1/1/16.
//
//

import UIKit
import MobileCoreServices
import Photos

public typealias ImageHandler = (_ result: SWImagePickerManagerResult) -> Void

open class SWImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    fileprivate var handler: ImageHandler!
    
    public override init() {
        
    }
    
    open func showImageSourcesSelector(fromViewController viewController: UIViewController, source: AnyObject, handler: @escaping ImageHandler) {
        self.handler = handler
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let lastPhoto = UIAlertAction(title: "Last Photo Taken", style: .default) { (action) -> Void in
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .authorized:
                //handle authorized status
                
                self.fetchLastPhotoTakenForTargetSize(viewController.view.bounds.size, completion: { (image) -> () in
                    
                    if let image = image {
                        let result = SWImagePickerManagerResult.image(image)
                        handler(result)
                    } else {
                        let result = SWImagePickerManagerResult.cancelled
                        handler(result)
                    }
                })
                
            case .denied, .restricted : break
                //handle denied status
            case .notDetermined:
                // ask for permissions
                PHPhotoLibrary.requestAuthorization() { (status) -> Void in
                    switch status {
                    case .authorized:
                        // as above
                        
                    self.fetchLastPhotoTakenForTargetSize(viewController.view.bounds.size, completion: { (image) -> () in
                        
                        if let image = image {
                            let result = SWImagePickerManagerResult.image(image)
                            handler(result)
                        } else {
                            let result = SWImagePickerManagerResult.cancelled
                            handler(result)
                        }
                    })
                        
                    case .denied, .restricted: break
                        // as above
                    case .notDetermined: break
                        // won't happen but still
                    }
                }
            }
        }
        actionSheet.addAction(lastPhoto)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { (action) -> Void in
            self.showImagePickerWithSourceType(.camera, fromViewController: viewController, source: source)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(takePhoto)
        }
        
        let photoLibrary = UIAlertAction(title: "Choose from Library", style: .default) { (action) -> Void in
            self.showImagePickerWithSourceType(.photoLibrary, fromViewController: viewController, source: source)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            actionSheet.addAction(photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] (action) -> Void in
            let result = SWImagePickerManagerResult.cancelled
            self.handler?(result)
        }
        
        actionSheet.addAction(cancel)
        
        if let barButtonItem = source as? UIBarButtonItem {
            actionSheet.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = source as? UIView {
            actionSheet.popoverPresentationController?.sourceView = sourceView
            actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
    
    fileprivate func showImagePickerWithSourceType(_ sourceType: UIImagePickerControllerSourceType, fromViewController viewController: UIViewController, source: AnyObject) {
        
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        picker.sourceType = sourceType
        picker.delegate = self
        picker.modalPresentationStyle = .popover
        
        if let barButtonItem = source as? UIBarButtonItem {
            picker.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = source as? UIView {
            picker.popoverPresentationController?.sourceView = sourceView
            picker.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        viewController.present(picker, animated: true, completion: {})
    }
    
    // MARK: - UIImagePickerControllerDelegate
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as! UIImage
        
        let result = SWImagePickerManagerResult.image(image)
        
        
        picker.dismiss(animated: true) { () -> Void in
            // handle after dismissed
            self.handler(result)
        }
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        let result = SWImagePickerManagerResult.cancelled
        
        picker.dismiss(animated: true) { () -> Void in
            self.handler(result)
        }
    }
    
    fileprivate func fetchLastPhotoTakenForTargetSize(_ size: CGSize, completion: @escaping (_ image: UIImage?) -> ()) {
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        
        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if let asset = result.firstObject {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: { () -> Void in
                imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, info) -> Void in
                    
                    print("info \(info)")
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(image)
                    })
                })
            })
        }
        
    }
}
