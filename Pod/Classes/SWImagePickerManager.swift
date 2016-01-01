//
//  SWImagePickerManager.swift
//  Pods
//
//  Created by Sarun Wongpatcharapakorn on 1/1/16.
//
//

import UIKit
import MobileCoreServices

public typealias ImageHandler = (image: UIImage) -> Void

public class SWImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var handler: ImageHandler?
    
    public override init() {
        
    }
    
    public func showImageSourcesSelector(fromViewController viewController: UIViewController, handler: ImageHandler) {
        self.handler = handler
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (action) -> Void in
            
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(takePhoto)
        }
        
        let photoLibrary = UIAlertAction(title: "Choose from Library", style: .Default) { (action) -> Void in
            self.showImagePickerWithSourceType(.PhotoLibrary, fromViewController: viewController)
        }
        
//        let lastPhoto = UIAlertAction(title: "Last Photo Taken", style: .Default) { (action) -> Void in
//            
//        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            actionSheet.addAction(photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(cancel)
        
        viewController.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func showImagePickerWithSourceType(sourceType: UIImagePickerControllerSourceType, fromViewController viewController: UIViewController) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        picker.sourceType = sourceType
        picker.delegate = self
        
        
        viewController.presentViewController(picker, animated: true, completion: {})
    }
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
 
        guard let handler = self.handler else {
            picker.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as! UIImage
        
        handler(image: image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}