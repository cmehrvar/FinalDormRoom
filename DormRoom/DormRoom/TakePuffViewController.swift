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

class TakePuffViewController: UIViewController, UITextFieldDelegate, AVCaptureFileOutputRecordingDelegate, AVAudioSessionDelegate {
    
    weak var rootController: MainRootViewController?
    
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var asset: AVURLAsset!
    
    var feed = String()
    var user = PFUser.currentUser()
    var imageUrl: String = String()
    var profilePictureUrl: String = String()
    var videoUrl: String = String()
    var globalVideoUrl: NSURL = NSURL()
    var globalVideoName: String = String()
    var globalVideoSaveUrl: String = String()
    
    var ms = 0
    var s = 0
    
    var startTime = NSTimeInterval()
    var timer:NSTimer = NSTimer()
    
    var isImage = true
    
    
    let frontOut = AVCaptureStillImageOutput()
    let backOut = AVCaptureStillImageOutput()
    
    let micDeviceInput: AVCaptureDeviceInput = AVCaptureDeviceInput()
    
    let frontVideoOut = AVCaptureMovieFileOutput()
    let backVideoOut = AVCaptureMovieFileOutput()
    
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
    @IBOutlet weak var HoldToRecordOutlet: UIView!
    @IBOutlet weak var TakeImageOutlet: UIImageView!
    @IBOutlet weak var RecordingIconOutlet: UIImageView!
    @IBOutlet weak var TimerOutlet: UILabel!
    @IBOutlet weak var VideoView: UIView!
    
    
    
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    //Actions
    @IBAction func changeCameraAction(sender: AnyObject) {
        frontCameraShown = !frontCameraShown
        configureCameraForCapture()
    }
    
    
    
    @IBAction func postPuff(sender: AnyObject) {
        
        rootController?.toggleTakePuff({ (complete) -> () in

            guard let actualController = self.rootController else {return}
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                actualController.mainController?.uploadOutlet.alpha = 1
                actualController.mainController?.TakeAPuffOutlet.alpha = 0
                
                self.CameraCaptureView.alpha = 1
                self.TakePuffButtonViewOutlet.alpha = 1
                self.ChangeCameraOutlet.alpha = 1
                self.HoldToRecordOutlet.alpha = 1
                
                self.PostButtonOutlet.alpha = 0
                
                self.view.endEditing(true)
                
                if self.isImage {
                    
                    print(self.isImage)
                    if let actualImage = self.TakenPuffOutlet.image {
                        self.uploadToAWS(actualImage)
                    }
                } else {
                    
                    print(self.isImage)
                    self.uploadVideo()
                    self.player.pause()
                }
            })
        })
        
        print("Upload in progress")
        
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            self.CameraCaptureView.alpha = 1
            self.TakePuffButtonViewOutlet.alpha = 1
            self.ChangeCameraOutlet.alpha = 1
            self.HoldToRecordOutlet.alpha = 1
            
            self.PostButtonOutlet.alpha = 0
            
            self.view.endEditing(true)
            
            self.TakenPuffOutlet.image = nil
            self.CaptionOutlet.text = nil
            print("cancelled")
            
            if !self.isImage {
            
            self.player.pause()
            }
        })
        
    }
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    
    
    //Functions
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        print("done recording")
        
        globalVideoUrl = outputFileURL
        
        self.TakenPuffOutlet.image = nil
        self.PostButtonOutlet.alpha = 1
        self.TakeImageOutlet.image = UIImage(named: "TakeAPuff")
        self.RecordingIconOutlet.image = nil
        
        timer.invalidate()
        ms = 0
        s = 0
        TimerOutlet.text = ""
        
        if let sampleUrl = outputFileURL {
            asset = AVURLAsset(URL: sampleUrl)
        }
        
        playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.player.replaceCurrentItemWithPlayerItem(self.playerItem)
            self.playerLayer.frame = self.VideoView.bounds
            self.player.actionAtItemEnd = .None
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.VideoView.layer.addSublayer(self.playerLayer)
            self.player.play()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: player.currentItem)
        
        
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.TakePuffButtonViewOutlet.alpha = 0
            self.CameraCaptureView.alpha = 0
            self.ChangeCameraOutlet.alpha = 0
            self.HoldToRecordOutlet.alpha = 0
            
        })
    }
    
    func update() {
        
        ms++
        
        switch ms {
            
        case 0:
            s = 0
            
        case 100:
            s = 1
            
        case 200:
            s = 2
            
        case 300:
            s = 3
            
        case 400:
            s = 4
            
        case 500:
            s = 5
            
        case 600:
            s = 6
            
        case 700:
            s = 7
            
        case 800:
            s = 8
            
        case 900:
            s = 9
            
        case 1000:
            s = 10
            
        default:
            break
            
            
        }
        
        TimerOutlet.text = "\(s)"
        
    }
    
    func takeVideo(sender: UILongPressGestureRecognizer) {
        
        isImage = false
        
        switch sender.state {
            
        case .Began:
            
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.HoldToRecordOutlet.alpha = 0
                self.TakeImageOutlet.image = UIImage(named: "Recording")
                self.RecordingIconOutlet.image = UIImage(named: "Recording")
            })
            
            if !frontCameraShown {
                
                backVideoOut.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 1)
                
                let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
                
                let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
                
                
                
                backVideoOut.startRecordingToOutputFileURL(fileURL, recordingDelegate: recordingDelegate)
                
            } else {
                
                frontVideoOut.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 1)
                
                let recordingDelegate:AVCaptureFileOutputRecordingDelegate? = self
                
                let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
                let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
                
                frontVideoOut.startRecordingToOutputFileURL(fileURL, recordingDelegate: recordingDelegate)
                
            }
            print("began")
            
        case .Ended:
            print("ended")
            
            PostButtonOutlet.alpha = 1
            RecordingIconOutlet.image = nil
            TakeImageOutlet.image = UIImage(named: "TakeAPuff")
            
            if !frontCameraShown {
                backVideoOut.stopRecording()
            } else {
                frontVideoOut.stopRecording()
            }
            
            timer.invalidate()
            ms = 0
            s = 0
            TimerOutlet.text = ""
            
        default:
            break
            
        }
        
    }
    
    func takeImage() {
        
        isImage = true
        
        PostButtonOutlet.alpha = 1
        
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
                    self.HoldToRecordOutlet.alpha = 0
                    
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
                    self.HoldToRecordOutlet.alpha = 0
                    
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
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
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
    
    func uploadVideo() {
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".mov")
        
        uploadRequest.body = globalVideoUrl
        uploadRequest.key = fileName
        uploadRequest.bucket = "dormroombucket"
        
        if let key = uploadRequest.key {
            globalVideoSaveUrl = "https://s3.amazonaws.com/dormroombucket/" + key
        }
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                print("successful Video upload")
                
                self.uploadProfilePicture()
                
                
            } else {
                print("error uploading: \(task.error)")
                let alertController = UIAlertController(title: "Shit...", message: "Error Uploading", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                if let actualController = self.rootController {
                    actualController.mainController?.uploadOutlet.alpha = 0
                }
                
            }
            return nil
        }
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
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
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
        
       let post = PFObject(className: "CanadaPuff")
        
        if isImage {
            post["ImageUrl"] = imageUrl
            post["VideoUrl"] = ""
        } else {
            post["VideoUrl"] = globalVideoSaveUrl
            post["ImageUrl"] = "download+latest+version.jpg"
        }
        
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
        post["Deleted"] = false
        post["IsImage"] = isImage
        
        post.saveInBackgroundWithBlock { (Bool, error: NSError?) -> Void in
            
            if error == nil {
                
                print("successfully posted to parse")
                self.TakenPuffOutlet.image = nil
                self.CaptionOutlet.text = nil
                self.rootController?.mainController?.loadFromParse({ (Bool) -> () in
                    print("Parse Loaded")
                })
                guard let actualController = self.rootController else {return}
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    actualController.mainController?.uploadOutlet.alpha = 0
                    actualController.mainController?.TakeAPuffOutlet.alpha = 1
                })
                
                
            } else {
                
                let alertController = UIAlertController(title: "Shit...", message: error?.localizedDescription, preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
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
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    func addTapGesture() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let imageTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "takeImage")
        let videoRecord: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "takeVideo:")
        TakePuffButtonViewOutlet.userInteractionEnabled = true
        TakePuffButtonViewOutlet.addGestureRecognizer(imageTap)
        TakePuffButtonViewOutlet.addGestureRecognizer(videoRecord)
        
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
        
        if !isImage {
        playerLayer.removeFromSuperlayer()
        }
        
        let captureSession = AVCaptureSession()
        
        CameraCaptureView.clipsToBounds = true
    
        let devices = AVCaptureDevice.devices()
        let audioDevices = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
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
        
        
        
        guard let audioCaptureDevice = audioDevices else {
            print("Unable to cast the first device as a capture device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: audioCaptureDevice)
            captureSession.addInput(input)
        } catch let error {
            print("Error was caught when trying to transform the device into a session input: \(error)")
        }
        
        
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        
        captureSession.startRunning()
        
        if !frontCameraShown {
            
            backOut.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(backOut) {
                captureSession.addOutput(backOut)
            }
            
            if captureSession.canAddOutput(backVideoOut) {
                captureSession.addOutput(backVideoOut)
            }
            
        } else {
            
            frontOut.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(frontOut) {
                captureSession.addOutput(frontOut)
            }
            
            if captureSession.canAddOutput(frontVideoOut) {
                captureSession.addOutput(frontVideoOut)
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
    
    
    
    func playerItemDidReachEnd(notification: NSNotification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seekToTime(kCMTimeZero)
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
