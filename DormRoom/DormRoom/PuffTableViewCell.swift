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
    
    var objectId = String()
    var like = Int()
    var dislike = Int()
    
    var feed: String = "CanadaPuff"
    
    var likedDisliked = [String : Bool]()
    
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
    
     @IBOutlet weak var SwipeConstraint: NSLayoutConstraint!
    
    
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

            if likedDisliked[objectId] != true {
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
        
        likedDisliked[objectId] = true
        LikeOutlet.text = "\(1 + like)"
        
    }
    
    
    func swipeDislike() {
        
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
        
        likedDisliked[objectId] = true
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
