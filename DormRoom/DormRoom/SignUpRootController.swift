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
    
    let drawerWidthConstant: CGFloat = 240.0
    
    var uniIsRevealed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStage()

        // Do any additional setup after loading the view.
    }
    
    //Constaints
    @IBOutlet weak var ChooseUniConstraint: NSLayoutConstraint!

    
    
    //Functions
    func setStage() {
        
        ChooseUniConstraint.constant = -drawerWidthConstant
        
    }
    
    func toggleChooseUni(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        if uniIsRevealed {
            panelOffset = -drawerWidthConstant
        }
        
        uniIsRevealed = !uniIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.ChooseUniConstraint.constant = panelOffset
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
