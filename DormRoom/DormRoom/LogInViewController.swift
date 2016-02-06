//
//  LogInViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDismissKeyboard()
        textFieldDelegates()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        loadGif()
        
    }
    
    //Outlets
    @IBOutlet weak var UsernameOutlet: UITextField!
    @IBOutlet weak var PasswordOutlet: UITextField!
    @IBOutlet weak var Gif: UIImageView!
    
    
    //Actions
    @IBAction func logInAction(sender: AnyObject) {
        
        guard let username = UsernameOutlet.text, password = PasswordOutlet.text else {return}
        
        PFUser.logInWithUsernameInBackground(username, password: password) { (user: PFUser?, error: NSError?) -> Void in
            
            if error == nil {
                
                print("successfully logged in")
                if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("MainController")) {
                    vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
                    self.presentViewController(vc, animated: true, completion: nil)
                }
                
                
            } else {
                
                let alertController = UIAlertController(title: "Hey", message: error?.localizedDescription, preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    //Functions
    func loadGif() {
        
        if let url = NSURL(string: "http://i.giphy.com/l2JI67RBdmHNxkHhC.gif") {
            
            Gif.image = UIImage.animatedImageWithAnimatedGIFURL(url)
        }
        
    }
    
    func textFieldDelegates() {
        
        UsernameOutlet.delegate = self
        PasswordOutlet.delegate = self
        
    }
    
    
    func addDismissKeyboard() {
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
        
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    let viewController = segue.destinationViewController as! SignUpRootController
    
    if gifImage != nil {
    viewController.gifImage = gifImage
    }
    
    }
    */
}
