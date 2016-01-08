//
//  TakePuffViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class TakePuffViewController: UIViewController, UITextFieldDelegate {
    
    weak var rootController: MainRootViewController?
    
    var feed = String()
    var user = PFUser.currentUser()
    var imageUrl: String = String()
    var profilePictureUrl: String = String()
    
    
    let frontOut = AVCaptureStillImageOutput()
    let backOut = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var frontCameraShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGesture()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        CaptionOutlet.delegate = self
        configureCameraForCapture()
        addUploadStuff()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        guard let actualPreviewLayer = previewLayer else {
            print("Unable to cast create a preview layer from the session")
            return
        }
        
        actualPreviewLayer.frame = CameraCaptureView.bounds
        actualPreviewLayer.position = CGPointMake(CameraCaptureView.bounds.midX, CameraCaptureView.bounds.midY)
        
    }
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    //Outlets
    @IBOutlet weak var TakenPuffOutlet: UIImageView!
    @IBOutlet weak var CaptionOutlet: UITextField!
    @IBOutlet weak var CameraCaptureView: UIView!
    @IBOutlet weak var TakePuffButtonViewOutlet: UIView!
    @IBOutlet weak var ChangeCameraOutlet: UIButton!
    @IBOutlet weak var PostButtonOutlet: UIView!
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    //Actions
    @IBAction func changeCameraAction(sender: AnyObject) {
        frontCameraShown = !frontCameraShown
        configureCameraForCapture()
    }
    
    
    @IBAction func takePuffAction(sender: AnyObject) {
        
        takeApuff()
        PostButtonOutlet.alpha = 1
        
    }
    
    @IBAction func postPuff(sender: AnyObject) {
        
        guard let image = self.TakenPuffOutlet.image else {print("step skipped")
            return}
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            guard let actualController = self.rootController else {return}
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                actualController.mainController?.uploadOutlet.alpha = 1
                actualController.mainController?.TakeAPuffOutlet.alpha = 0
                
                self.CameraCaptureView.alpha = 1
                self.TakePuffButtonViewOutlet.alpha = 1
                self.ChangeCameraOutlet.alpha = 1
                
                self.PostButtonOutlet.alpha = 0
                
                self.view.endEditing(true)
                
                self.uploadToAWS(image)
            })
            
        })

        print("Upload in progress")
        
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            self.CameraCaptureView.alpha = 1
            self.TakePuffButtonViewOutlet.alpha = 1
            self.ChangeCameraOutlet.alpha = 1
            
            self.PostButtonOutlet.alpha = 0
            
            self.view.endEditing(true)
            
            self.TakenPuffOutlet.image = nil
            self.CaptionOutlet.text = nil
            print("cancelled")
        })
        
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    //Functions
    func takeApuff() {
        if !frontCameraShown {
            
            guard let videoConnection = backOut.connectionWithMediaType(AVMediaTypeVideo) else {
                print("Error creating video connection")
                return
            }
            
            
            backOut.captureStillImageAsynchronouslyFromConnection(videoConnection) { (imageDataSampleBuffer, error) -> Void in
                
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer), image = UIImage(data: imageData) else {
                    return
                }
                
                self.TakenPuffOutlet.image = image
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.TakePuffButtonViewOutlet.alpha = 0
                    self.CameraCaptureView.alpha = 0
                    self.ChangeCameraOutlet.alpha = 0
                    
                })
            }
        } else {
            
            guard let videoConnection = frontOut.connectionWithMediaType(AVMediaTypeVideo) else {
                print("Error creating video connection")
                return
            }
            
            frontOut.captureStillImageAsynchronouslyFromConnection(videoConnection) { (imageDataSampleBuffer, error) -> Void in
                
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer), image = UIImage(data: imageData) else {
                    return
                }
                
                self.TakenPuffOutlet.image = image
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.TakePuffButtonViewOutlet.alpha = 0
                    self.CameraCaptureView.alpha = 0
                    self.ChangeCameraOutlet.alpha = 0
                    
                })
            }
        }
    }
    
    func uploadToAWS(image: UIImage) {
        
        let uploadRequest = imageUploadRequest(image)
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                
                print("successful image upload")
                self.uploadProfilePicture()
                
            } else {
                print("error uploading: \(task.error)")
                
                let alertController = UIAlertController(title: "Shit...", message: "Error Uploading", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                if let actualController = self.rootController {
                actualController.mainController?.uploadOutlet.alpha = 0
                }
            }
            return nil
        }
    }
    
    func imageUploadRequest(image: UIImage) -> AWSS3TransferManagerUploadRequest {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.25)
        
        imageData?.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "dormroombucket"
        
        if let key = uploadRequest.key {
            imageUrl = key
        }
        
        return uploadRequest
        
    }
    
    func uploadProfilePicture() {
        
        let userProfilePictureFile: PFFile = user?["profilePicture"] as! PFFile
        var userProfilePictureData: NSData = NSData()
        
        do {
            userProfilePictureData = try userProfilePictureFile.getData()
        } catch let error {
            print(error)
        }
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        userProfilePictureData.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "dormroombucket"
        
        if let key = uploadRequest.key {
            profilePictureUrl = key
        }
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                print("successful Profile upload")
                self.saveToParse()
                
            } else {
                print("error uploading: \(task.error)")
                let alertController = UIAlertController(title: "Shit...", message: "Error Uploading", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                if let actualController = self.rootController {
                    actualController.mainController?.uploadOutlet.alpha = 0
                }
                
            }
            return nil
        }
    }
    
    func saveToParse(){
        
        do {
            try user?.fetch()
        } catch let error {
            print("error fetching new user: \(error)")
        }
        
        if feed != "CanadaPuff" {
            
            let post = PFObject(className: "CanadaPuff")
            
            post["ImageUrl"] = imageUrl
            post["Caption"] = CaptionOutlet.text
            post["Like"] = 0
            post["Dislike"] = 0
            post["ProfilePictureUrl"] = profilePictureUrl
            post["UniversityName"] = user?["universityName"] as! String
            post["Username"] = user?.username
            post["Safe"] = true
            post["Comments"] = []
            post["CommentProfiles"] = []
            post["CommentDates"] = []

            post.saveEventually()
            
        } else {
            
            let uniName = user?["universityName"] as! String
            
            let post = PFObject(className: uniName)
            
            post["ImageUrl"] = imageUrl
            post["Caption"] = CaptionOutlet.text
            post["Like"] = 0
            post["Dislike"] = 0
            post["ProfilePictureUrl"] = profilePictureUrl
            post["UniversityName"] = user?["universityName"] as! String
            post["Username"] = user?.username
            post["Safe"] = true
            post["Comments"] = []
            post["CommentProfiles"] = []
            post["CommentDates"] = []
            
            post.saveEventually()
        }
        
        let post = PFObject(className: feed)
        
        post["ImageUrl"] = imageUrl
        post["Caption"] = CaptionOutlet.text
        post["Like"] = 0
        post["Dislike"] = 0
        post["ProfilePictureUrl"] = profilePictureUrl
        post["UniversityName"] = user?["universityName"] as! String
        post["Username"] = user?.username
        post["Safe"] = true
        post["Comments"] = []
        post["CommentProfiles"] = []
        post["CommentDates"] = []
        
        post.saveInBackgroundWithBlock { (Bool, error: NSError?) -> Void in
            
            if error == nil {
                
                print("successfully posted to parse")
                self.TakenPuffOutlet.image = nil
                self.CaptionOutlet.text = nil
                self.rootController?.mainController?.loadFromParse({ () -> Void in
                    
                })
                
                guard let actualController = self.rootController else {return}
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    actualController.mainController?.uploadOutlet.alpha = 0
                    actualController.mainController?.TakeAPuffOutlet.alpha = 1
                })
                
                
            } else {
                
                let alertController = UIAlertController(title: "Shit...", message: error?.localizedDescription, preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                if let actualController = self.rootController {
                    actualController.mainController?.uploadOutlet.alpha = 0
                }
                
            }
        }
    }
    
    
    func addUploadStuff(){
        
        let error = NSErrorPointer()
        
        do{
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating upload directory failed. Error: \(error)")
        }
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addTapGesture() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var length = Int()
        
        if let actualTextField: String = textField.text {
            
            length = actualTextField.characters.count + string.characters.count - range.length
            
        }
        
        return length <= 20
        
    }
    
    
    func configureCameraForCapture() {
        
        previewLayer?.removeFromSuperlayer()
        
        let captureSession = AVCaptureSession()
        
        CameraCaptureView.clipsToBounds = true
        
        let devices = AVCaptureDevice.devices()
        var actualDevice: AVCaptureDevice! = nil
        
        for device in devices {
            
            if !frontCameraShown {
                if device.position == .Back {
                    actualDevice = device as! AVCaptureDevice
                }
            } else {
                
                if device.position == .Front {
                    actualDevice = device as! AVCaptureDevice
                }
            }
        }
        
        guard let cameraCaptureDevice = actualDevice else {
            print("Unable to cast the first device as a capture device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: cameraCaptureDevice)
            captureSession.addInput(input)
        } catch let error {
            print("Error was caught when trying to transform the device into a session input: \(error)")
        }
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        captureSession.startRunning()
        
        if !frontCameraShown {
            
            backOut.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(backOut) {
                captureSession.addOutput(backOut)
            }
            
        } else {
            
            frontOut.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(frontOut) {
                captureSession.addOutput(frontOut)
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        guard let actualPreviewLayer = previewLayer else {
            print("Unable to cast create a preview layer from the session")
            return
        }
        
        actualPreviewLayer.frame = CameraCaptureView.bounds
        actualPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        actualPreviewLayer.position = CGPointMake(CameraCaptureView.bounds.midX, CameraCaptureView.bounds.midY)
        CameraCaptureView.layer.addSublayer(actualPreviewLayer)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
        
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
