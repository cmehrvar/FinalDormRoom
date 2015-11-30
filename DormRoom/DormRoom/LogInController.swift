//
//  LogInController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-29.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class LogInController: UIViewController, UITextFieldDelegate {
    
    //Outlets
    @IBOutlet weak var UsernameOutlet: UITextField!
    @IBOutlet weak var PasswordOutlet: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.UsernameOutlet.delegate = self
        self.PasswordOutlet.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

    
    
    
    @IBAction func logInAction(sender: AnyObject) {
        
        
        
        
        
    }
    
    
    
    @IBAction func signUpFunction(sender: AnyObject) {
        
        
        
        
        
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
