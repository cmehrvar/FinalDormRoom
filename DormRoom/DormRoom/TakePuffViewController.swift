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
    let user = PFUser.currentUser()
    
    let frontOut = AVCaptureStillImageOutput()
    let backOut = AVCaptureStillImageOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var frontCameraShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChangeCameraOutlet.layer.cornerRadius = 5
        
        addTapGesture()
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        CaptionOutlet.delegate = self
        configureCameraForCapture()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        guard let actualPreviewLayer = previewLayer else {
            print("Unable to cast create a preview layer from the session")
            return
        }
        
        actualPreviewLayer.frame = CameraCaptureView.bounds
        actualPreviewLayer.position = CGPointMake(CameraCaptureView.bounds.midX, CameraCaptureView.bounds.midY)
        
    }
    
    
    //Outlets
    @IBOutlet weak var TakenPuffOutlet: UIImageView!
    @IBOutlet weak var CaptionOutlet: UITextField!
    @IBOutlet weak var CameraCaptureView: UIView!
    @IBOutlet weak var TakePuffButtonViewOutlet: UIView!
    @IBOutlet weak var ChangeCameraOutlet: UIButton!
    
    //Actions
    @IBAction func changeCameraAction(sender: AnyObject) {
        frontCameraShown = !frontCameraShown
        configureCameraForCapture()
    }
    
    
    @IBAction func takePuffAction(sender: AnyObject) {
        
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
    
    @IBAction func postPuff(sender: AnyObject) {
        
        do {
            try user?.fetch()
        } catch let error {
            print("error fetching new user: \(error)")
        }
        
        let post = PFObject(className: feed)
        
        guard let image = TakenPuffOutlet.image else {return}
        let data = UIImageJPEGRepresentation(image, 0.5)
        
        guard let actualData = data else {return}
        let file = PFFile(data: actualData)
        
        post["Image"] = file
        post["Caption"] = CaptionOutlet.text
        post["Like"] = 0
        post["Dislike"] = 0
        post["ProfilePicture"] = user?["profilePicture"] as! PFFile
        post["UniversityFile"] = user?["universityFile"] as! PFFile
        post["UniversityName"] = user?["universityName"] as! String
        
        
        post.saveInBackgroundWithBlock { (Bool, error: NSError?) -> Void in
            
            if error == nil {
                
                guard let actualController = self.rootController else {return}
                
                actualController.mainController?.loadFromParse()
                
                
            } else {
                
                let alertController = UIAlertController(title: "Shit...", message: error?.localizedDescription, preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
        
        self.rootController?.toggleTakePuff({ (complete) -> () in
            
            self.CameraCaptureView.alpha = 1
            self.TakePuffButtonViewOutlet.alpha = 1
            self.ChangeCameraOutlet.alpha = 1
            self.TakenPuffOutlet.image = nil
            self.CaptionOutlet.text = nil
            
        })
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            self.CameraCaptureView.alpha = 1
            self.TakePuffButtonViewOutlet.alpha = 1
            self.ChangeCameraOutlet.alpha = 1
            self.TakenPuffOutlet.image = nil
            self.CaptionOutlet.text = nil
            print("cancelled")
        })
        
    }

    //Functions
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
       
        return length <= 10
        
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
