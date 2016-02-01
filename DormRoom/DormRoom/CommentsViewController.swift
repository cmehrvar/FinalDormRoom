//
//  CommentsViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-19.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    weak var rootController: MainRootViewController?
    
    var comments = [String]()
    var profilePictures = [String]()
    var dates = [NSDate]()
    var usernames = [String]()
    var universities = [String]()
    var votes = [Int]()
    var commentIds = [String]()

    var objectId = String()
    
    var textIsEditing = false
    
    let user = PFUser.currentUser()
    
    var isUploading = false
    
    var imageUrl = String()
    var profilePictureUrl = String()
    var uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
    
    var loading = false
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "CommentsTitle"))
        
        CommentText.delegate = self
        
        handleKeyboard()
        addTapGesture()
        addRefresh()
        // Do any additional setup after loading the view.
    }
    
    
    //Outlets
    @IBOutlet weak var CommentText: UITextView!
    @IBOutlet weak var CommentTableView: UITableView!
    @IBOutlet weak var UploadIcon: UIImageView!
    
    
    
    //Actions
    @IBAction func post(sender: AnyObject) {
        
        if !isUploading {
            
            if CommentText.text != "" {
                
                isUploading = true
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    self.UploadIcon.alpha = 1
                    self.uploadProfilePicture()
                    
                })
                
                view.endEditing(true)
            }
        }
    }
    
    
    
    @IBAction func hideButton(sender: AnyObject) {
        
        print("hide tapped")
        
        view.endEditing(true)
        
        comments.removeAll()
        profilePictures.removeAll()
        dates.removeAll()
        usernames.removeAll()
        universities.removeAll()
        votes.removeAll()
        commentIds.removeAll()
        
        CommentTableView.reloadData()
        
        rootController?.toggleComments({ (Bool) -> () in
            print("Comments Closed")
        })
        
    }
    
    //Functions
    func uploadProfilePicture() {
        
        let userProfilePictureFile: PFFile = user?["profilePicture"] as! PFFile
        var userProfilePictureData: NSData = NSData()
        
        do {
            userProfilePictureData = try userProfilePictureFile.getData()
        } catch let error {
            print(error)
        }
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        userProfilePictureData.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "dormroombucket"
        
        if let key = uploadRequest.key {
            uploadProfileUrl = uploadProfileUrl + key
        }
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                print("successful Profile upload")
                self.saveToParse()
                
            } else {
                print("error uploading: \(task.error)")
                let alertController = UIAlertController(title: "Shit...", message: "Error Uploading", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
                self.isUploading = false
                self.uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
            }
            return nil
        }
    }
    
    
    func saveToParse() {
        
        print(objectId)
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString
        let query = PFQuery(className: "CanadaPuff")
        let date = NSDate()
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print(error)
            } else if let post = post {
                
                self.comments = post["NewComments"] as! [String]
                self.profilePictures = post["NewCommentProfiles"] as! [String]
                self.dates = post["NewCommentDates"] as! [NSDate]
                self.usernames = post["NewCommentUsernames"] as! [String]
                self.universities = post["NewCommentUniversities"] as! [String]
                self.votes = post["NewCommentVotes"] as! [Int]
                
                if post["CommentIds"] == nil {
                    self.commentIds = []
                } else {
                    self.commentIds = post["CommentIds"] as! [String]
                }
                
                post["NewComments"] = [self.CommentText.text] + self.comments
                post["NewCommentProfiles"] = [self.uploadProfileUrl] + self.profilePictures
                post["NewCommentDates"] = [date] + self.dates
                post["NewCommentUniversities"] = [self.user?["universityName"] as! String] + self.universities
                post["CommentIds"] = [fileName] + self.commentIds
                
                if let actualUsername = self.user?.username {
                    post["NewCommentUsernames"] = [actualUsername] + self.usernames
                }
                
                post["NewCommentVotes"] = [0] + self.votes
                
                post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        print("comment saved")
                        
                        self.CommentText.text = ""
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.UploadIcon.alpha = 0
                            self.isUploading = false
                            self.uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
                        })
                        
                        self.loadFromParse()
                        self.rootController?.mainController?.loadFromParse({ (Bool) -> () in
                            
                        })
                        
                    } else {
                        
                        print("what the fuck")
                        
                        let alertController = UIAlertController(title: "Shit!", message: "There was an error uploading your comment", preferredStyle:  UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            self.UploadIcon.alpha = 0
                            self.isUploading = false
                            self.uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
                            
                        })
                    }
                })
            }
        }
    }
    
    
    
    func addRefresh() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Comment Away")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func refresh(sender: AnyObject) {
        
        loadFromParse()
        refreshControl.endRefreshing()
    }
    
    
    func loadFromParse() {
        
        let query = PFQuery(className: "CanadaPuff")
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if !self.loading {
                
                self.loading = true
                
                if error == nil && post != nil {
                    
                    self.comments.removeAll()
                    self.profilePictures.removeAll()
                    self.dates.removeAll()
                    self.usernames.removeAll()
                    self.universities.removeAll()
                    self.votes.removeAll()
                    self.commentIds.removeAll()
                    
                    do {
                        try post?.fetch()
                    } catch let error {
                        print(error)
                    }
                    
                    if post?["NewCommentUsernames"] != nil {
                        print("Adding")
                        self.comments = post?["NewComments"] as! [String]
                        self.profilePictures = post?["NewCommentProfiles"] as! [String]
                        self.dates = post?["NewCommentDates"] as! [NSDate]
                        self.usernames = post?["NewCommentUsernames"] as! [String]
                        self.universities = post?["NewCommentUniversities"] as! [String]
                        self.votes = post?["NewCommentVotes"] as! [Int]
                        
                        if post?["CommentIds"] == nil {
                            self.commentIds = []
                        } else {
                            self.commentIds = post?["CommentIds"] as! [String]
                        }

                        self.CommentTableView.reloadData()
                        
                    } else {
                        print("replacing")
                        post?["NewComments"] = []
                        post?["NewCommentProfiles"] = []
                        post?["NewCommentDates"] = []
                        post?["NewCommentUsernames"] = []
                        post?["NewCommentUniversities"] = []
                        post?["NewCommentVotes"] = []
                        post?["CommentIds"] = []
                        
                        post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                            
                            if error == nil {
                                
                                print("success")
                                
                            } else {
                                print("error")
                            }
                        })
                    }
                    
                } else {
                    print(error)
                }
                self.loading = false
                
            }
        }
    }
    
    
    func addTapGesture() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    //TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.addSubview(refreshControl)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentsCell", forIndexPath: indexPath) as! CommentsCell
        
        var hasBeenVotedOn = false
        
        var commentsVotedOn = [String]()
        
        if user?["votes"] == nil {
            commentsVotedOn = []
        } else {
            commentsVotedOn = user?["votes"] as! [String]
        }
   
        for commentVotedOn in commentsVotedOn {
            
            if commentVotedOn == commentIds[indexPath.row] {
                hasBeenVotedOn = true
            }
        }
        
        if !hasBeenVotedOn {
            
            cell.VoteUpOutlet.alpha = 1
            cell.VoteDownOutlet.alpha = 1
            
        } else {
            
            cell.VoteUpOutlet.alpha = 0
            cell.VoteDownOutlet.alpha = 0
            
        }
        
        cell.selectionStyle = .None
        
        cell.Comment.text = comments[indexPath.row]
        cell.TimePosted.text = timeAgoSince(dates[indexPath.row])
        cell.ProfilePicture.sd_setImageWithURL(NSURL(string: profilePictures[indexPath.row]))
        cell.Username.text = usernames[indexPath.row] + ","
        
        
        if votes[indexPath.row] > 0 {
            
            cell.VoteCount.text = "\(votes[indexPath.row])"
            cell.plusMinusIcon.image = UIImage(named: "plus")
            
        } else if votes[indexPath.row] == 0 {
            
            cell.plusMinusIcon.image = nil
            cell.VoteCount.text = "\(votes[indexPath.row])"
            
        } else if votes[indexPath.row] < 0 {
            
            cell.plusMinusIcon.image = UIImage(named: "minus")
            let positiveVotes = -(votes[indexPath.row])
            cell.VoteCount.text = "\(positiveVotes)"
            
        }
        
        cell.commentViewController = self
        cell.commentId = commentIds[indexPath.row]
        
        cell.votes = votes
        cell.indexPath = indexPath.row
        cell.objectId = objectId
        
        switch universities[indexPath.row] {
            
        case "Brock":
            cell.UniversityName.text = "Brock Univeristy"
            
        case "Calgary":
            cell.UniversityName.text = "University of Calgary"
            
        case "Carlton":
            cell.UniversityName.text = "Carlton University"
            
        case "Dalhousie":
            cell.UniversityName.text = "Dalhousie University"
            
        case "Laurier":
            cell.UniversityName.text = "Wilfred Laurier University"
            
        case "McGill":
            cell.UniversityName.text = "McGill University"
            
        case "Mac":
            cell.UniversityName.text = "McMaster University"
            
        case "Mun":
            cell.UniversityName.text = "Memorial University"
            
        case "Ottawa":
            cell.UniversityName.text = "University of Ottawa"
            
        case "Queens":
            cell.UniversityName.text = "Queens University"
            
        case "Ryerson":
            cell.UniversityName.text = "Ryerson University"
            
        case "UBC":
            cell.UniversityName.text = "University of British Colombia"
            
        case "UofT":
            cell.UniversityName.text = "University of Toronto"
            
        case "Western":
            cell.UniversityName.text = "University of Western Ontario"
            
        case "York":
            cell.UniversityName.text = "York University"
            
        case "OtherUni":
            cell.UniversityName.text = "Other"
            
        default:
            break
            
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        print("began")
        
        if CommentText.text == "Comment Here" {
            CommentText.text = ""
        }
        
        self.textIsEditing = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("ended")
        
        if CommentText.text == "" {
            CommentText.text = "Comment Here"
        }
        
        self.textIsEditing = false
    }
    
    
    func handleKeyboard() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
