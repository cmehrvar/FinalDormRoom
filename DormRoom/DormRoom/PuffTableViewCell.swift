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
    
    var objectId = String()
    var like = Int()
    var dislike = Int()
    
    var feed: String = "CanadaPuff"
    
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
    @IBOutlet weak var UniversityOutlet: UIImageView!
    @IBOutlet weak var ProfileOutlet: UIImageView!
    @IBOutlet weak var SwipeViewOutlet: UIImageView!
    @IBOutlet weak var ReadSwipeViewOutlet: UIView!
    @IBOutlet weak var ThumbsUpOutlet: UIImageView!
    @IBOutlet weak var ThumbsDownOutlet: UIImageView!
    @IBOutlet weak var UsernameOutlet: UILabel!
    @IBOutlet weak var LikeButtonOutlet: UIImageView!
    @IBOutlet weak var DislikeButtonOutlet: UIImageView!
    @IBOutlet weak var SwipeConstraint: NSLayoutConstraint!
    @IBOutlet weak var CommentNumber: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var dislikeView: UIView!
    
    
    
    //Functions
    func swipeLikeDislike() {
        
        let longPressRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
        longPressRecognizer.delegate = self
        self.addGestureRecognizer(longPressRecognizer)
        
        //Adding Pan Gesture
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panOnCell:")
        panRecognizer.delegate = self
        self.addGestureRecognizer(panRecognizer)
        
        let likeTapRecognizer = UITapGestureRecognizer(target: self, action: "swipeLike")
        likeView.addGestureRecognizer(likeTapRecognizer)
        
        let dislikeTapRecognizer = UITapGestureRecognizer(target: self, action: "swipeDislike")
        dislikeView.addGestureRecognizer(dislikeTapRecognizer)
        
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
                    puff.saveEventually()
                }
                
            } else {
                print("\(error)")
            }
        }
        
        var array: [String] = user?["liked"] as! [String]
        array = [objectId] + array
        user?["liked"] = array
        user?.saveInBackgroundWithBlock({ (Bool, error:NSError?) -> Void in
            
            do {
                try self.user?.fetch()
            } catch let error {
                print(error)
            }
            
        })
        
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
                
            } else {
                print("\(error)")
            }
        }
        
        var array: [String] = user?["liked"] as! [String]
        array = [objectId] + array
        user?["liked"] = array
        user?.saveInBackgroundWithBlock({ (Bool, error:NSError?) -> Void in
            
            do {
                try self.user?.fetch()
            } catch let error {
                print(error)
            }
        
        })
        
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
