//
//  ViewController.swift
//  SWImagePickerManager
//
//  Created by Sarun Wongpatcharapakorn on 01/01/2016.
//  Copyright (c) 2016 Sarun Wongpatcharapakorn. All rights reserved.
//

import UIKit
import SWImagePickerManager

class ViewController: UIViewController {
    let manager = SWImagePickerManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTapOpenImageSelector(sender: AnyObject) {
        self.manager.showImageSourcesSelector(fromViewController: self) { (image) -> () in
            print("Got image: \(image)")
        }
    }
}

