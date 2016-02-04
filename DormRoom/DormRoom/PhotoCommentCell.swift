//
//  PhotoCommentCell.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-02-01.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class PhotoCommentCell: UITableViewCell {

    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var TimePosted: UILabel!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var UniversityName: UILabel!
    @IBOutlet weak var VoteUpOutlet: UIButton!
    @IBOutlet weak var VoteDownOutlet: UIButton!
    @IBOutlet weak var VoteCount: UILabel!
    @IBOutlet weak var Comment: UITextView!
    @IBOutlet weak var plusMinusIcon: UIImageView!
    @IBOutlet weak var photoComment: UIImageView!
    @IBOutlet weak var DeleteOutlet: UIButton!
    
    
    var isDeleted = [Bool]()
    var votes = [Int]()
    var currentVote = Int()
    
    var actualIndexPath: Int!

    
    
    var photoUrl = String()
    var usernameVar = String()
    var uniVar = String()
    var timePostedVar = String()
    var profileUrl = String()
    
    var objectId: String!
    
    var commentId: String!
    var commentViewController: CommentsViewController!
    
    let user = PFUser.currentUser()
    
    @IBAction func fullSizeImage(sender: AnyObject) {
        
        guard let actualController = commentViewController.rootController else {return}
        
        actualController.imageController?.ImageOutlet.sd_setImageWithURL(NSURL(string: photoUrl))
        
        actualController.imageController?.InfoViewOutlet.alpha = 0
        actualController.imageController?.CaptionViewOutlet.alpha = 0
        
        commentViewController.rootController?.toggleFullSizeImage({ (Bool) -> () in
            
            print("Full Size Opened")
            
        })
        
    }
    
    @IBAction func VoteUp(sender: AnyObject) {
        
        print("Vote Down")
        
        var vote = currentVote
        vote = vote + 1
        votes[actualIndexPath] = vote
        
        VoteCount.text = "\(votes[actualIndexPath])"
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.VoteUpOutlet.alpha = 0
            self.VoteDownOutlet.alpha = 0
            
        }
        
        let query = PFQuery(className: "CanadaPuff")
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                
                post?["NewCommentVotes"] = self.votes
                
                post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        var userVotes: [String]!
                        
                        if self.user?["votes"] == nil {
                            userVotes = []
                        } else {
                            userVotes = self.user?["votes"] as! [String]
                        }
                        
                        userVotes.append(self.commentId)
                        self.user?["votes"] = userVotes
                        
                        self.user?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                do {
                                    try self.user?.fetch()
                                    self.commentViewController.loadFromParse()
                                    
                                } catch let error {
                                    print(error)
                                }
                            } else {
                                print(error)
                            }
                        })
                        
                    } else {
                        
                        print(error)
                        
                    }
                })
                
            } else {
                print(error)
            }
        }
    }
    
    @IBAction func VoteDown(sender: AnyObject) {
        
        print("Vote Down")
        
        var vote = currentVote
        vote = vote + 1
        votes[actualIndexPath] = vote
        
        VoteCount.text = "\(votes[actualIndexPath])"
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.VoteUpOutlet.alpha = 0
            self.VoteDownOutlet.alpha = 0
            
        }
        
        let query = PFQuery(className: "CanadaPuff")
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                
                post?["NewCommentVotes"] = self.votes
                
                post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        var userVotes: [String]!
                        
                        if self.user?["votes"] == nil {
                            userVotes = []
                        } else {
                            userVotes = self.user?["votes"] as! [String]
                        }
                        
                        userVotes.append(self.commentId)
                        self.user?["votes"] = userVotes
                        
                        self.user?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                do {
                                    try self.user?.fetch()
                                    self.commentViewController.loadFromParse()
                                    
                                } catch let error {
                                    print(error)
                                }
                            } else {
                                print(error)
                            }
                        })
                        
                    } else {
                        
                        print(error)
                        
                    }
                })
                
            } else {
                print(error)
            }
        }
    }
    
    
    @IBAction func Delete(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "So...", message: "You wanna delete this?", preferredStyle:  UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
            
            
            self.isDeleted[self.actualIndexPath] = true
            
            let query = PFQuery(className: "CanadaPuff")
            
            query.getObjectInBackgroundWithId(self.objectId, block: { (post: PFObject?, error: NSError?) -> Void in
                
                if error == nil {
                    
                    post?["IsCommentDeleted"] = self.isDeleted
                    
                    post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                        
                        self.commentViewController.loadFromParse()
                        
                    })
                    
                } else {
                    
                    print(error)
                    
                }
            })
        }))
        
        self.commentViewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        
        
        
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
