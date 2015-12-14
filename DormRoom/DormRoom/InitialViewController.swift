//
//  InitialViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-05.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
