//
//  MainRootViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class MainRootViewController: UIViewController {
    
    let drawerWidthConstant: CGFloat = 240.0
    var menuIsRevealed = false
    var takePuffIsRevealed = false
    var changeUniIsRevealed = false
    
    weak var mainController: MainPuffViewController?
    weak var changeUniController: ChangeUniViewController?
    weak var takePuffController: TakePuffViewController?
    weak var menuController: MenuViewController?
    
    //Constraints
    @IBOutlet weak var MenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var ChangeUniBottom: NSLayoutConstraint!
    @IBOutlet weak var ChangeUniTop: NSLayoutConstraint!
    
    
    //Outlets
    @IBOutlet weak var TakePuffContainerOutlet: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setMenuStage()
        setChangeUniStage()
 
    }
    
    
    //Functions
    func setChangeUniStage() {
        ChangeUniTop.constant = view.bounds.size.height
        ChangeUniBottom.constant = -view.bounds.size.height
    }
    
    func setMenuStage() {
        MenuConstraint.constant = -drawerWidthConstant
    }
    
    func toggleChangeUni(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        if changeUniIsRevealed {
            panelOffset = view.bounds.size.height
        }
        
        changeUniIsRevealed = !changeUniIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.ChangeUniTop.constant = panelOffset
            self.ChangeUniBottom.constant = -panelOffset
            self.view.layoutIfNeeded()
            
            }) { (complete) -> Void in
                
                completion(complete)
        }
    }
    
    func toggleMenu(completion:(Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        if menuIsRevealed {
            panelOffset = -drawerWidthConstant
        }
        
        menuIsRevealed = !menuIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.MenuConstraint.constant = panelOffset
            self.view.layoutIfNeeded()
            
            }) { (complete) -> Void in
                
                completion(complete)
                
        }
    }
    
    func toggleTakePuff(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 1
        
        if takePuffIsRevealed {
            panelOffset = 0
        }
        
        takePuffIsRevealed = !takePuffIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.TakePuffContainerOutlet.alpha = panelOffset
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
        
        if segue.identifier == "MenuSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, menu = navController.topViewController as? MenuViewController else {return}
            menuController = menu
            menuController?.rootController = self
            
        } else if segue.identifier == "ChangeUniSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, changeUni = navController.topViewController as? ChangeUniViewController else {return}
            changeUniController = changeUni
            changeUniController?.rootController = self
            
        } else if segue.identifier == "TakePuffSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, takePuff = navController.topViewController as? TakePuffViewController else {return}
            takePuffController = takePuff
            takePuffController?.rootController = self
            
        } else if segue.identifier == "MainSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, main = navController.topViewController as? MainPuffViewController else {return}
            mainController = main
            mainController?.rootController = self
            
        }
    }
}
