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
    
    var votes = [Int]()
    var indexPath: Int!
    var objectId: String!
    
    let user = PFUser.currentUser()
    
    @IBAction func VoteUp(sender: AnyObject) {
        
        VoteCount.text = "\(votes[indexPath] + 1)"
        
        print("Vote Up")
        
        var vote = votes[indexPath]
        vote = vote + 1
        votes[indexPath] = vote
        
        let query = PFQuery(className: "CanadaPuff")
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                
                post?["NewCommentVotes"] = self.votes
                
                do {
                    try post?.save()
                } catch let error {
                    print(error)
                }
                
            } else {
                print("Error getting object")
            }
        }
    }
    
    @IBAction func VoteDown(sender: AnyObject) {
        
        VoteCount.text = "\(votes[indexPath] - 1)"
        
        print("Vote Down")
        
        var vote = votes[indexPath]
        vote = vote - 1
        votes[indexPath] = vote
        
        let query = PFQuery(className: "CanadaPuff")
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error == nil {
                
                post?["NewCommentVotes"] = self.votes
                
                do {
                    try post?.save()
                } catch let error {
                    print(error)
                }
                
                
            } else {
                print("Error getting object")
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
