//
//  InitialViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-05.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    var uploadRequests = [AWSS3TransferManagerUploadRequest]()
    var uploadFileUrls = [NSURL]()
    let image: UIImage = UIImage(named: "Crest")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       let error = NSErrorPointer()
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'upload' directory failed. Error: \(error)")
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func uploadPicture(sender: AnyObject) {
        selectPicture()
    }
    
    func selectPicture() {
        print("selectPictureTapped")
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        imageData?.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "dormroombucket"
        
        uploadRequests.append(uploadRequest)
        uploadFileUrls.append(fileURL)
        
        upload(uploadRequest)
        
    }
    
    
    func upload(uploadRequest: AWSS3TransferManagerUploadRequest) {
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                
                print("successful upload")
                
            } else {
                
                print("failed upload")
                
            }
            return nil
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        if PFUser.currentUser() == nil {
            
            print("no user")
            
            if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("LogInController")) {
                vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
        } else {
            
            print("user logged in")
            
            if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("MainController")) {
                vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
