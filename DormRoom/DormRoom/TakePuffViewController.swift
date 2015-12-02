//
//  TakePuffViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class TakePuffViewController: UIViewController, UITextFieldDelegate {
    
    weak var rootController: MainRootViewController?
    
    var feed: String = ""
    let user = PFUser.currentUser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        CaptionOutlet.delegate = self
    }
    
    //Functions
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //Outlets
    @IBOutlet weak var TakenPuffOutlet: UIImageView!
    @IBOutlet weak var CaptionOutlet: UITextField!
    
    //Actions
    @IBAction func postPuff(sender: AnyObject) {
        
        do {
            try user?.fetch()
        } catch let error {
            print("error fetching new user: \(error)")
        }
        
        let post = PFObject(className: "CanadaPuff")
        
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
                
                self.rootController?.toggleTakePuff({ (complete) -> () in
                    
                    actualController.mainController?.loadFromParse()
                    
                })
                
            } else {
                
                //post.saveEventually()
                
            }
        }
        
        self.TakenPuffOutlet.image = nil
        self.CaptionOutlet.text = nil
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        TakenPuffOutlet.image = nil
        CaptionOutlet.text = nil
        rootController?.toggleTakePuff({ (complete) -> () in
            print("cancelled")
        })
        
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
