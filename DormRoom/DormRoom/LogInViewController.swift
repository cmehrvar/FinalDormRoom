//
//  LogInViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    var keyboardIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handleKeyboard()
        addDismissKeyboard()
        textFieldDelegates()
    }
    
    //Outlets
    @IBOutlet weak var UsernameOutlet: UITextField!
    @IBOutlet weak var PasswordOutlet: UITextField!
    
    
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
    func textFieldDelegates() {
        
        UsernameOutlet.delegate = self
        PasswordOutlet.delegate = self
        
    }
    
    func handleKeyboard() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func addDismissKeyboard() {
        
        let dismissKeyboard: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(dismissKeyboard)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if !keyboardIsShown {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y -= keyboardSize.height
            }
            
            keyboardIsShown = !keyboardIsShown
            
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if keyboardIsShown {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                self.view.frame.origin.y += keyboardSize.height
            }
            
            keyboardIsShown = !keyboardIsShown
        }
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
