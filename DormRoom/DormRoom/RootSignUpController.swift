//
//  RootSignUpController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-29.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class RootSignUpController: UIViewController {
    
    weak var signUpController: SignUpController?
    weak var chooseUniController: ChooseUniViewController?
    
       
    var hasSetStage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if !hasSetStage {
            hasSetStage = true
            
        }
    }
    
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "SignUpSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, signUp = navController.topViewController as? SignUpController else {return}
            
            signUpController = signUp
            signUpController?.rootController = self
            
        } else if segue.identifier == "ChooseUniSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, chooseUni = navController.topViewController as? ChooseUniViewController else {return}
            chooseUniController = chooseUni
            chooseUniController?.rootController = self
            
        }
    }
}
