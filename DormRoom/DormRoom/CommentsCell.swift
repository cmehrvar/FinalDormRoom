//
//  CommentsCell.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-22.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var TimePosted: UILabel!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var UniversityName: UILabel!
    @IBOutlet weak var VoteUpOutlet: UIButton!
    @IBOutlet weak var VoteDownOutlet: UIButton!
    @IBOutlet weak var VoteCount: UILabel!
    @IBOutlet weak var Comment: UILabel!
    @IBOutlet weak var plusMinusIcon: UIImageView!
    
    
    var votes = [Int]()
    var indexPath: Int!
    var objectId: String!
    
    var commentId: String!
    var commentViewController: CommentsViewController!
    
    
    let user = PFUser.currentUser()
    
    @IBAction func VoteUp(sender: AnyObject) {
        
        print("Vote Down")
        
        var vote = votes[indexPath]
        vote = vote + 1
        votes[indexPath] = vote
        
        VoteCount.text = "\(votes[indexPath])"
        
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
        
 
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            var vote = self.votes[self.indexPath]
            vote = vote - 1
            self.votes[self.indexPath] = vote
            
            self.VoteCount.text = "\(self.votes[self.indexPath])"
            
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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
