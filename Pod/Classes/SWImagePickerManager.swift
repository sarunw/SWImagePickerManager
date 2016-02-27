//
//  SWImagePickerManager.swift
//  Pods
//
//  Created by Sarun Wongpatcharapakorn on 1/1/16.
//
//

import UIKit
import MobileCoreServices

public typealias ImageHandler = (result: SWImagePickerManagerResult) -> Void

public class SWImagePickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var handler: ImageHandler?
    
    public override init() {
        
    }
    
    public func showImageSourcesSelector(fromViewController viewController: UIViewController, source: AnyObject, handler: ImageHandler) {
        self.handler = handler
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (action) -> Void in
            self.showImagePickerWithSourceType(.Camera, fromViewController: viewController, source: source)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            actionSheet.addAction(takePhoto)
        }
        
        let photoLibrary = UIAlertAction(title: "Choose from Library", style: .Default) { (action) -> Void in
            self.showImagePickerWithSourceType(.PhotoLibrary, fromViewController: viewController, source: source)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            actionSheet.addAction(photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel) { [unowned self] (action) -> Void in
            let result = SWImagePickerManagerResult.Cancelled
            self.handler?(result: result)
        }
        
        actionSheet.addAction(cancel)
        
        if let barButtonItem = source as? UIBarButtonItem {
            actionSheet.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = source as? UIView {
            actionSheet.popoverPresentationController?.sourceView = sourceView
            actionSheet.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        
        viewController.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    private func showImagePickerWithSourceType(sourceType: UIImagePickerControllerSourceType, fromViewController viewController: UIViewController, source: AnyObject) {
        
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.mediaTypes = [kUTTypeImage as String]
        picker.sourceType = sourceType
        picker.delegate = self
        picker.modalPresentationStyle = .Popover
        
        if let barButtonItem = source as? UIBarButtonItem {
            picker.popoverPresentationController?.barButtonItem = barButtonItem
        } else if let sourceView = source as? UIView {
            picker.popoverPresentationController?.sourceView = sourceView
            picker.popoverPresentationController?.sourceRect = sourceView.bounds
        }
        
        viewController.presentViewController(picker, animated: true, completion: {})
    }
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
 
        guard let handler = self.handler else {
            picker.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as! UIImage
        
        let result = SWImagePickerManagerResult.Image(image)
        handler(result: result)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        if let handler = self.handler {
            let result = SWImagePickerManagerResult.Cancelled
            handler(result: result)
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}