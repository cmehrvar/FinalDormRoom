//
//  PuffTableViewCell.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class PuffTableViewCell: UITableViewCell {
    
    var isExpanded = false
    
    let user = PFUser.currentUser()
    
    var mainController: MainPuffViewController!
    
    var imageUrl = String()
    var profileUrl = String()
    var uniName = String()
    var username = String()
    var timePostedVar = String()
    var captionVar = String()
    var likeVar = String()
    var dislikeVar = String()
    var repDel = String()
    
    var objectId = String()
    var like = Int()
    var dislike = Int()
    
    var feed: String = "CanadaPuff"
    
    var indexPath: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        swipeLikeDislike()
        // Initialization code
    }
    
    //Outlets
    @IBOutlet weak var ImageOutlet: UIImageView!
    @IBOutlet weak var LikeOutlet: UILabel!
    @IBOutlet weak var DislikeOutlet: UILabel!
    @IBOutlet weak var CaptionOutlet: UILabel!
    @IBOutlet weak var ProfileOutlet: UIImageView!
    @IBOutlet weak var UsernameOutlet: UILabel!
    @IBOutlet weak var UniversityNameOutlet: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var LikeButtonOutlet: UIImageView!
    @IBOutlet weak var DislikeButtonOutlet: UIImageView!
    @IBOutlet weak var SecondRecentComment: UILabel!
    @IBOutlet weak var ViewHowManyComments: UILabel!
    @IBOutlet weak var SecondRecentUsername: UILabel!
    @IBOutlet weak var MostRecentUsername: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var dislikeView: UIView!
    @IBOutlet weak var MostRecentCommentOutlet: UILabel!
    @IBOutlet weak var SwipeViewOutlet: UIImageView!
    @IBOutlet weak var ReadSwipeViewOutlet: UIView!
    @IBOutlet weak var ThumbsUpOutlet: UIImageView!
    @IBOutlet weak var ThumbsDownOutlet: UIImageView!
    @IBOutlet weak var ReportOutlet: UILabel!
    
    
    
    @IBOutlet weak var SwipeConstraint: NSLayoutConstraint!
    
    @IBAction func fullScreen(sender: AnyObject) {
        
        guard let actualController = mainController.rootController else {return}
        
        actualController.imageController?.ImageOutlet.sd_setImageWithURL(NSURL(string: imageUrl))
        actualController.imageController?.CaptionOutlet.text = captionVar
        actualController.imageController?.LikeOutlet.text = likeVar
        actualController.imageController?.DislikeOutlet.text = dislikeVar
        actualController.imageController?.CaptionViewOutlet.alpha = 1
        actualController.imageController?.InfoViewOutlet.alpha = 1
        actualController.imageController?.objectId = objectId
        actualController.imageController?.isComment = false
        actualController.imageController?.ReportOutlet.text = repDel
        actualController.imageController?.actualUsername = username
        
        
        mainController.rootController?.toggleFullSizeImage({ (Bool) -> () in
            
            print("FullScreenToggled")
            
        })
        
        
    }
    
    
    
    @IBAction func dislike(sender: AnyObject) {
        
        swipeDislike()
        
    }
    
    
    @IBAction func like(sender: AnyObject) {
        
        swipeLike()
        
    }
    
    
    
    @IBAction func ReportDelete(sender: AnyObject) {
        
        print("Report Delete")
        
        guard let actualUsername = UsernameOutlet.text else {return}
        
        if actualUsername != user?.username {
            
            let alertController = UIAlertController(title: "So...", message: "You wanna report \(actualUsername)?", preferredStyle:  UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                
                var blockedPuffs = [String]()
                
                do {
                    try self.user?.fetch()
                } catch let error {
                    print(error)
                }
                
                blockedPuffs = self.user?["blockedPuffs"] as! [String]
                
                self.user?["blockedPuffs"] = [actualUsername] + blockedPuffs
                
                self.user?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        do {
                            try self.user?.fetch()
                            
                            self.mainController.loadFromParse({ (Bool) -> () in
                                
                            })
                            
                        } catch let error {
                            print(error)
                        }
                        
                    })
                    
                })

            }))
            
            mainController.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            let alertController = UIAlertController(title: "So...", message: "You wanna delete this?", preferredStyle:  UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                
                let query = PFQuery(className: self.feed)
                query.getObjectInBackgroundWithId(self.objectId, block: { (post: PFObject?, error: NSError?) -> Void in
                    
                    post?["Deleted"] = true
                    post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                        
                        self.mainController.loadFromParse({ (Bool) -> () in
                            
                        })
                        
                        
                    })
                })
            }))
            
            mainController.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    @IBAction func ViewComments(sender: AnyObject) {
        
        print("Did Select Row")

        mainController.PlayPauseImage.image = UIImage(named: "playIcon")
        
        guard let actualController = mainController.rootController else {return}
        
        actualController.commentsController?.objectId = mainController.objectId[indexPath]
        
        actualController.commentsController?.loadFromParse()

        mainController.rootController?.toggleComments({ (Bool) -> () in
            
            print("Comments Toggled")
            
            if self.mainController.videoPlayer != nil {
                self.mainController.videoPlayer.pause()
            }
            
        })

        
        mainController.commentsOpened = true
        

    }
    
    
    
    //Functions
    func swipeLikeDislike() {
        
        let longPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        longPressRecognizer.delegate = self
        self.addGestureRecognizer(longPressRecognizer)
        
        //Adding Pan Gesture
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panOnCell:")
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
    }
    
    func expandImage() {
        
        isExpanded = true
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.ReadSwipeViewOutlet.alpha = 1
            self.ReadSwipeViewOutlet.transform = CGAffineTransformMakeScale(0.4, 0.4)
            
        }
    }
    
    func contractImage() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.ReadSwipeViewOutlet.alpha = 0
            self.ReadSwipeViewOutlet.transform = CGAffineTransformIdentity
            
            }) { (complete) -> Void in
                
                self.SwipeConstraint.constant = 0
                self.ThumbsUpOutlet.alpha = 0
                self.ThumbsDownOutlet.alpha = 0
        }
    }
    
    func longPressed(sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
            
        case .Began:
            
            if user?["liked"] == nil {
                user?["liked"] = []
            }
            
            let likedObjects: [String] = user?["liked"] as! [String]
            var liked = false
            
            for likedObject in likedObjects {
                
                if likedObject == objectId {
                    liked = true
                }
            }
            
            if !liked {
                expandImage()
            }
            
        case .Ended:
            contractImage()
            
        default:
            break
            
        }
    }
    
    func panOnCell(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(self)
        
        switch sender.state {
            
        case .Changed:
            
            if isExpanded {
                SwipeConstraint.constant = translation.x
                
                if translation.x >= 50 {
                    
                    ThumbsUpOutlet.alpha = 1
                    ThumbsDownOutlet.alpha = 0
                    
                } else if translation.x <= -50 {
                    
                    ThumbsUpOutlet.alpha = 0
                    ThumbsDownOutlet.alpha = 1
                    
                } else {
                    
                    ThumbsUpOutlet.alpha = 0
                    ThumbsDownOutlet.alpha = 0
                    
                }
            }
            
        case .Ended:
            
            isExpanded = false
            
            if SwipeConstraint.constant <= -50 {
                swipeDislike()
            } else if SwipeConstraint.constant >= 50 {
                swipeLike()
            }
            
        default:
            break
        }
    }
    
    func swipeLike() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.LikeButtonOutlet.transform = CGAffineTransformMakeScale(6,6)
            self.LikeButtonOutlet.alpha = 0
            
            self.DislikeButtonOutlet.transform = CGAffineTransformMakeScale(0.15, 0.15)
            self.DislikeButtonOutlet.alpha = 0
            
            }) { (Bool) -> Void in
                
                self.LikeButtonOutlet.image = nil
                self.likeView.userInteractionEnabled = false
                
                self.DislikeButtonOutlet.image = nil
                self.dislikeView.userInteractionEnabled = false
                
                self.LikeButtonOutlet.transform = CGAffineTransformIdentity
                self.LikeButtonOutlet.alpha = 1
                
                self.DislikeButtonOutlet.transform = CGAffineTransformIdentity
                self.DislikeButtonOutlet.alpha = 1
                
        }
        
        
        let query = PFQuery(className: feed)
        
        query.getObjectInBackgroundWithId(objectId) { (puff: PFObject?, error: NSError?) -> Void in
            
            do {
                try puff?.fetch()
            } catch let error {
                print("error fetching new like/dislike: \(error)")
            }
            
            if error == nil {
                
                if let puff = puff {
                    puff["Like"] = 1 + (puff["Like"] as! Int)
                    puff.saveInBackground()
                }
                
                var array: [String] = self.user?["liked"] as! [String]
                array = [self.objectId] + array
                self.user?["liked"] = array
                self.user?.saveInBackgroundWithBlock({ (Bool, error:NSError?) -> Void in
                    
                    print("savedLiked")
                    
                    do {
                        try self.user?.fetch()
                    } catch let error {
                        print(error)
                    }
                    
                })
            } else {
                print("\(error)")
            }
        }
        
        LikeOutlet.text = "\(1 + like)"
    }
    
    func swipeDislike() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.DislikeButtonOutlet.transform = CGAffineTransformMakeScale(6,6)
            self.DislikeButtonOutlet.alpha = 0
            
            self.LikeButtonOutlet.transform = CGAffineTransformMakeScale(0.15,0.15)
            self.LikeButtonOutlet.alpha = 0
            
            }) { (Bool) -> Void in
                
                self.LikeButtonOutlet.image = nil
                self.likeView.userInteractionEnabled = false
                
                self.DislikeButtonOutlet.image = nil
                self.dislikeView.userInteractionEnabled = false
                
                self.LikeButtonOutlet.transform = CGAffineTransformIdentity
                self.LikeButtonOutlet.alpha = 1
                
                self.DislikeButtonOutlet.transform = CGAffineTransformIdentity
                self.DislikeButtonOutlet.alpha = 1
                
        }
        
        
        let query = PFQuery(className: feed)
        
        query.getObjectInBackgroundWithId(objectId) { (puff: PFObject?, error: NSError?) -> Void in
            
            do {
                try puff?.fetch()
            } catch let error {
                print("error fetching new like/dislike: \(error)")
            }
            
            if error == nil {
                
                if let puff = puff {
                    puff["Dislike"] = 1 + (puff["Dislike"] as! Int)
                    puff.saveEventually()
                }
                
                var array: [String] = self.user?["liked"] as! [String]
                array = [self.objectId] + array
                self.user?["liked"] = array
                self.user?.saveInBackgroundWithBlock({ (Bool, error:NSError?) -> Void in
                    
                    print("savedDisliked")
                    
                    do {
                        try self.user?.fetch()
                    } catch let error {
                        print(error)
                    }
                    
                })
                
                
            } else {
                print("\(error)")
            }
        }
        
        DislikeOutlet.text = "\(1 + dislike)"
        
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
