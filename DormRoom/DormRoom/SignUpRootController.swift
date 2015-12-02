//
//  SignUpRootController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class SignUpRootController: UIViewController {
    
    weak var signUpViewController: SignUpViewController?
    weak var chooseUniViewController: ChooseUniViewController?
    
    var uniIsRevealed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStage()
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        // Do any additional setup after loading the view.
    }
    
    //Constaints
    @IBOutlet weak var TopConstraint: NSLayoutConstraint!
    @IBOutlet weak var BottomConstraint: NSLayoutConstraint!
    
    
    //Functions
    func setStage() {
        
        TopConstraint.constant = view.bounds.size.height
        BottomConstraint.constant = -view.bounds.size.height
        
    }
    
    func toggleChooseUni(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        if uniIsRevealed {
            panelOffset = view.bounds.size.height
        }
        
        uniIsRevealed = !uniIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.TopConstraint.constant = panelOffset
            self.BottomConstraint.constant = -panelOffset
            self.view.layoutIfNeeded()
            
            }) { (complete) -> Void in
                completion(complete)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SignUpSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, signUp = navController.topViewController as? SignUpViewController else {return}
            signUpViewController = signUp
            signUpViewController?.rootController = self
            
        } else if segue.identifier == "ChooseUniSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, chooseUni = navController.topViewController as? ChooseUniViewController else {return}
            chooseUniViewController = chooseUni
            chooseUniViewController?.rootController = self
            
        }
    }
}
