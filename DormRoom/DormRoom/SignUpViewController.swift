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
    
    //Outlets
    @IBOutlet weak var UsernameOutlet: UITextField!
    @IBOutlet weak var PasswordOutlet: UITextField!
    @IBOutlet weak var EmailOutlet: UITextField!
    @IBOutlet weak var ProfileOutlet: RoundedImage!
    @IBOutlet weak var UniOutlet: RoundedImage!
    @IBOutlet weak var CheckmarkOutlet: UIImageView!
    @IBOutlet weak var ReadTermsView: WhiteButton!
    @IBOutlet weak var termsView: UIView!
    
    
    
    //Actions
    @IBAction func termsAction(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.termsView.alpha = 1
            
        }
        
    }
    
    @IBAction func okAction(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.termsView.alpha = 0
        }
        
    }
    @IBAction func termsOfAgreement(sender: AnyObject) {
        
        rootController?.uniIsRevealed = false
        
    }
    
    @IBAction func signUp(sender: AnyObject) {
        
        if CheckmarkOutlet.alpha == 0 {
            
            let alertController = UIAlertController(title: "Hey", message: "Read Terms Aggreement", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Chate", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        } else

        
        if ProfileOutlet.image == UIImage(named: "ChooseProfile") {
            
            let alertController = UIAlertController(title: "Puff You", message: "Take a profile picture", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Chate", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else if UniOutlet.image == UIImage(named: "ChooseUni") {
            
            let alertController = UIAlertController(title: "Puff You", message: "Choose a university", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Chate", style: .Cancel, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
            
        else {
            
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
                    
                    if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("InstructionController")) {
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
        
        ProfileOutlet.userInteractionEnabled = true
        UniOutlet.userInteractionEnabled = true
        view.userInteractionEnabled = true
        ReadTermsView.userInteractionEnabled = true
        
        ProfileOutlet.addGestureRecognizer(profilePictureRecognizer)
        UniOutlet.addGestureRecognizer(universityRecognizer)
        view.addGestureRecognizer(dismissKeyboard)
        ReadTermsView.addGestureRecognizer(readTermsRecognizer)
        
    }
    
    func readTerms() {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.CheckmarkOutlet.alpha = 1

        }
    }
    
    func uniTapped() {
        
        print("uniTapped")
        rootController?.toggleChooseUni({ (complete) -> () in
            
        })
    }
    
    
    func profileTapped() {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        self.presentViewController(cameraProfile, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let temp: UIImage = image
        ProfileOutlet.image = temp
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
