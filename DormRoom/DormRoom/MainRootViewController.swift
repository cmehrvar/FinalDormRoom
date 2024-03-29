//
//  MainRootViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation

class MainRootViewController: UIViewController {
    
    let drawerWidthConstant: CGFloat = 240.0
    var menuIsRevealed = false
    var takePuffIsRevealed = false
    var changeUniIsRevealed = false
    var commentsIsRevealed = false
    var fullSizeImageIsRevealed = false

    
    let user = PFUser.currentUser()
    
    weak var mainController: MainPuffViewController?
    weak var changeUniController: ChangeUniViewController?
    weak var takePuffController: TakePuffViewController?
    weak var menuController: MenuViewController?
    weak var commentsController: CommentsViewController?
    weak var imageController: FullSizeImageViewController?

    
    //Constraints
    @IBOutlet weak var MenuConstraint: NSLayoutConstraint!
    @IBOutlet weak var ChangeUniBottom: NSLayoutConstraint!
    @IBOutlet weak var ChangeUniTop: NSLayoutConstraint!
    @IBOutlet weak var CommentsLeading: NSLayoutConstraint!
    @IBOutlet weak var CommentsTrailing: NSLayoutConstraint!
    @IBOutlet weak var FullSizeImageLeading: NSLayoutConstraint!
    @IBOutlet weak var FullSizeImageTrailing: NSLayoutConstraint!

    
    //Outlets
    @IBOutlet weak var TakePuffContainerOutlet: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user?["liked"] == nil {
            user?["liked"] = []
            user?.saveInBackground()
        }

        setMenuStage()
        setChangeUniStage()
        setCommentStage()
        setFullSizeStage()
 
    }
    
    
    //Functions
    func setChangeUniStage() {
        ChangeUniTop.constant = view.bounds.size.height
        ChangeUniBottom.constant = -view.bounds.size.height
    }
    
    func setMenuStage() {
        MenuConstraint.constant = -drawerWidthConstant
    }
    
    func setCommentStage() {
        
        CommentsLeading.constant = -view.bounds.size.width
        CommentsTrailing.constant = view.bounds.size.width
        
    }
    
    
    func setFullSizeStage() {
        
        FullSizeImageLeading.constant = -view.bounds.size.width
        FullSizeImageTrailing.constant = view.bounds.size.width
        
    }
    
    
    func toggleFullSizeImage(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        let player: AVPlayer!
        
        if mainController?.videoPlayer != nil {
            
            player = mainController?.videoPlayer
            player?.pause()
            mainController?.PlayPauseImage.image = UIImage(named: "playIcon")
            
        }
        
        if fullSizeImageIsRevealed {
            panelOffset = view.bounds.size.height
        }
        
        fullSizeImageIsRevealed = !fullSizeImageIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.FullSizeImageLeading.constant = -panelOffset
            self.FullSizeImageTrailing.constant = panelOffset
            self.view.layoutIfNeeded()
            
            }) { (complete) -> Void in
                completion(complete)
        }
    }

    
    
    
    func toggleComments(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        let player: AVPlayer!
        
        if mainController?.videoPlayer != nil {
            
            player = mainController?.videoPlayer
            player?.pause()
            mainController?.PlayPauseImage.image = UIImage(named: "playIcon")
            
        }
        
        if commentsIsRevealed {
            panelOffset = view.bounds.size.height
        }
        
        commentsIsRevealed = !commentsIsRevealed
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.CommentsLeading.constant = -panelOffset
            self.CommentsTrailing.constant = panelOffset
            self.view.layoutIfNeeded()
            
            }) { (complete) -> Void in
                completion(complete)
        }
    }

    
    
    func toggleChangeUni(completion: (Bool) -> ()) {
        
        var panelOffset: CGFloat = 0
        
        let player: AVPlayer!
        
        if mainController?.videoPlayer != nil {
            
            player = mainController?.videoPlayer
            player?.pause()
            mainController?.PlayPauseImage.image = UIImage(named: "playIcon")
            
        }
        
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
        
        let player: AVPlayer!
        
        if mainController?.videoPlayer != nil {
            
            player = mainController?.videoPlayer
            player?.pause()
            mainController?.PlayPauseImage.image = UIImage(named: "playIcon")
            
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
        
        let player: AVPlayer!
        
        if mainController?.videoPlayer != nil {
            
            player = mainController?.videoPlayer
            player?.pause()
            mainController?.PlayPauseImage.image = UIImage(named: "playIcon")
            
        }
        
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
            
        } else if segue.identifier == "CommentsSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, comments = navController.topViewController as? CommentsViewController else {return}
            commentsController = comments
            commentsController?.rootController = self

        } else if segue.identifier == "FullSizeSegue" {
            
            guard let navController = segue.destinationViewController as? UINavigationController, fullSizeController = navController.topViewController as? FullSizeImageViewController else {return}
            imageController = fullSizeController
            imageController?.rootController = self
        }
    }
}
