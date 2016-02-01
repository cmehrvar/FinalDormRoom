//
//  VideoTableViewCell.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-14.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation

class VideoTableViewCell: UITableViewCell {
    
    var isExpanded = false
    
    let user = PFUser.currentUser()
    
    var videoUrl = String()
    
    var fullyVisible = false
    
    var objectId = String()
    var like = Int()
    var dislike = Int()
    
    var mainController: MainPuffViewController!
    
    var feed: String = "CanadaPuff"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        swipeLikeDislike()
        // Initialization code
    }
    
    
    
    //Outlets
    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var UsernameOutlet: UILabel!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var HowManyComments: UILabel!
    @IBOutlet weak var MostRecentUsername: UILabel!
    @IBOutlet weak var SecondUsername: UILabel!
    @IBOutlet weak var MostRecentComment: UILabel!
    @IBOutlet weak var SecondComment: UILabel!
    @IBOutlet weak var LikeOutlet: UILabel!
    @IBOutlet weak var DislikeOutlet: UILabel!
    @IBOutlet weak var CaptionOutlet: UILabel!
    @IBOutlet weak var ProfileOutlet: UIImageView!
    @IBOutlet weak var LikeButtonOutlet: UIImageView!
    @IBOutlet weak var DislikeButtonOutlet: UIImageView!
    @IBOutlet weak var CommentNumber: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var dislikeView: UIView!
    @IBOutlet weak var ReportOutlet: UIButton!
    @IBOutlet weak var UniversityName: UILabel!
    
    
    
    
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
    
    
    //Functions
    func swipeLikeDislike() {
                
        let likeTapRecognizer = UITapGestureRecognizer(target: self, action: "swipeLike")
        likeView.userInteractionEnabled = true
        likeView.addGestureRecognizer(likeTapRecognizer)
        
        let dislikeTapRecognizer = UITapGestureRecognizer(target: self, action: "swipeDislike")
        dislikeView.userInteractionEnabled = true
        dislikeView.addGestureRecognizer(dislikeTapRecognizer)
        
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
