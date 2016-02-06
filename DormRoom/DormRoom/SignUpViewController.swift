//
//  SignUpViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    weak var rootController: SignUpRootController?
    let user = PFUser()
    
    var termsOpen = false
    
    var uniChosen = false
    var universityName = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        UsernameOutlet.delegate = self
        PasswordOutlet.delegate = self
        EmailOutlet.delegate = self
        
        addRecognizers()
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if let url = NSURL(string: "http://i.giphy.com/l2JI67RBdmHNxkHhC.gif") {
            
            Gif.image = UIImage.animatedImageWithAnimatedGIFURL(url)
        }
    }
    

    //Outlets
    @IBOutlet weak var UsernameOutlet: UITextField!
    @IBOutlet weak var PasswordOutlet: UITextField!
    @IBOutlet weak var EmailOutlet: UITextField!
    @IBOutlet weak var ProfileOutlet: RoundedImage!
    @IBOutlet weak var UniOutlet: RoundedImage!
    @IBOutlet weak var CheckmarkOutlet: UIImageView!
    @IBOutlet weak var ReadTermsView: WhiteButton!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var ImageBlur: UIView!
    @IBOutlet weak var Gif: UIImageView!
    @IBOutlet weak var BlankProfileOutlet: UIImageView!
    @IBOutlet weak var ChooseProfile: UIImageView!
    
    
    
    //Actions
    @IBAction func backAction(sender: AnyObject) {
        
        if termsOpen {
            
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.termsView.alpha = 0
                self.termsOpen = false
            }
        } else {
            
            if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("LogInController")) {
                vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
    }
    

    @IBAction func termsAction(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.termsView.alpha = 1
            self.termsOpen = true
            
        }
        
    }
    
    @IBAction func okAction(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.CheckmarkOutlet.alpha = 1
            self.termsView.alpha = 0
            self.termsOpen = false
        }
        
    }
    
    @IBAction func termsOfAgreement(sender: AnyObject) {
        
        rootController?.uniIsRevealed = false
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        if CheckmarkOutlet.alpha == 0 {
            
            let alertController = UIAlertController(title: "Hey", message: "Read Terms Aggreement", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if ProfileOutlet.alpha == 0 {
            
            let alertController = UIAlertController(title: "Hey", message: "Take a profile picture", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if !uniChosen {
            
            let alertController = UIAlertController(title: "Hey", message: "Choose a university", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if PasswordOutlet.text == "" {
            
            let alertController = UIAlertController(title: "Hey", message: "Enter a password", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if UsernameOutlet.text == "" {
            
            let alertController = UIAlertController(title: "Hey", message: "Enter a username", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if EmailOutlet.text == "" {
            
            let alertController = UIAlertController(title: "Hey", message: "Enter an email", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            guard let actualImage = ProfileOutlet.image else {return}
            
            let profilePictureData = UIImageJPEGRepresentation(actualImage, 0.25)
            
            guard let actualProfiledata = profilePictureData else {return}
            
            user.username = UsernameOutlet.text
            user.password = PasswordOutlet.text
            user.email = EmailOutlet.text
            user["profilePicture"] = PFFile(data: actualProfiledata)
            user["universityName"] = universityName
            user["firstTime"] = true
            user["blockedPuffs"] = []
            
            user.signUpInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                
                if error == nil {
                    //call main root controller
                    print("successfully signed up")
                    
                    if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("MainController")) {
                        vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                        self.presentViewController(vc, animated: true, completion: nil)
                        
                    }

                } else {
                    
                    let alertController = UIAlertController(title: "Shit...", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
            })
        }
    }
    
    
    //Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addRecognizers() {
        
        let profilePictureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped")
        let universityRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "uniTapped")
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let readTermsRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "readTerms")
        let dismissSlideIn: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "closeChooseUni")
        let anotherProfileRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped")
        
        ImageBlur.userInteractionEnabled = true
        ChooseProfile.userInteractionEnabled = true
        UniOutlet.userInteractionEnabled = true
        view.userInteractionEnabled = true
        ReadTermsView.userInteractionEnabled = true
        ProfileOutlet.userInteractionEnabled = true
        
        ImageBlur.addGestureRecognizer(dismissSlideIn)
        ChooseProfile.addGestureRecognizer(profilePictureRecognizer)
        UniOutlet.addGestureRecognizer(universityRecognizer)
        view.addGestureRecognizer(dismissKeyboard)
        ReadTermsView.addGestureRecognizer(readTermsRecognizer)
        ProfileOutlet.addGestureRecognizer(anotherProfileRecognizer)
        
    }
    
    
    func closeChooseUni() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.ImageBlur.alpha = 0
            
        })
        
        rootController?.toggleChooseUni({ (Bool) -> () in
            print("Choose Uni Closed")
            
            
        })
    }
    

    func readTerms() {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.CheckmarkOutlet.alpha = 1

        }
    }
    
    func uniTapped() {
        
        print("uniTapped")
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.ImageBlur.alpha = 1
        }
        
        rootController?.toggleChooseUni({ (complete) -> () in
            
        })
    }
    
    
    func profileTapped() {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        let alertController = UIAlertController(title: "Smile!", message: "Take a pic or choose from gallery?", preferredStyle:  UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
            }
            
            self.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let temp: UIImage = image
        ProfileOutlet.image = temp
        
        ChooseProfile.alpha = 0
        BlankProfileOutlet.alpha = 1
        ProfileOutlet.alpha = 1
        
        BlankProfileOutlet.alpha = 1
        dismissViewControllerAnimated(true, completion: nil)

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
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
