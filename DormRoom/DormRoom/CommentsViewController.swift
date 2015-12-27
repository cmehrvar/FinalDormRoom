//
//  CommentsViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-19.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    weak var rootController: MainRootViewController?
    
    var comments = [String]()
    var profilePictures = [String]()
    var objectId = String()
    var feed = String()
    
    let user = PFUser.currentUser()
    
    var isUploading = false
    
    var imageUrl = String()
    var profilePictureUrl = String()
    var uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
    
    var loading = false
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseSwipe()
        addTapGesture()
        addRefresh()
        // Do any additional setup after loading the view.
    }
    
    
    //Outlets
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var University: UIImageView!
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var CommentText: UITextView!
    @IBOutlet weak var CommentTableView: UITableView!
    @IBOutlet weak var commentIcon: UIImageView!
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
        
        rootController?.toggleComments({ (Bool) -> () in
            
            guard let actualController = self.rootController else {return}
            
            actualController.mainController?.commentsOpened = false
            
            self.view.endEditing(true)
            self.CommentText.text = ""
            self.commentIcon.alpha = 0
            self.comments.removeAll()
            self.CommentTableView.reloadData()
            
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
                
                if let actualController = self.rootController {
                    actualController.mainController?.uploadOutlet.alpha = 0
                    self.isUploading = false
                }
                
            }
            return nil
        }
    }

    
    func saveToParse() {
        
        let query = PFQuery(className: feed)
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print(error)
            } else if let post = post {
                
                self.comments = post["Comments"] as! [String]
                self.profilePictures = post["CommentProfiles"] as! [String]
                
                post["Comments"] = [self.CommentText.text] + self.comments
                post["CommentProfiles"] = [self.uploadProfileUrl] + self.profilePictures
                
                post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        self.CommentText.text = ""
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.commentIcon.alpha = 1
                            self.UploadIcon.alpha = 0
                            self.isUploading = false
                        })
                        
                        
                        self.loadFromParse()
                        
                    } else {
                        print("error")
                        
                        let alertController = UIAlertController(title: "Shit!", message: "There was an error uploading your comment", preferredStyle:  UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Chate", style: UIAlertActionStyle.Cancel, handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            
                            self.UploadIcon.alpha = 0
                            self.isUploading = false
                            
                        })
                    }
                })
            }
        }
    }
    
    
    
    func addRefresh() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Keep on Puffin'")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func refresh(sender: AnyObject) {
        
        loadFromParse()
        refreshControl.endRefreshing()
    }
    
    
    func loadFromParse() {
        
        let query = PFQuery(className: feed)
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if !self.loading {
                
                self.loading = true
                
                if error == nil && post != nil {
                    
                    self.comments.removeAll()
                    self.profilePictures.removeAll()
                    
                    do {
                        try post?.fetch()
                    } catch let error {
                        print(error)
                    }
                    
                    if post?["Comments"] != nil {
                        
                        self.comments = post?["Comments"] as! [String]
                        self.profilePictures = post?["CommentProfiles"] as! [String]
                        
                        self.CommentTableView.reloadData()
                        
                    } else {
                        
                        
                        let query = PFQuery(className: self.feed)
                        query.getObjectInBackgroundWithId(self.objectId) { (post: PFObject?, error: NSError?) -> Void in
                            
                            if error != nil {
                                print(error)
                            } else if let post = post {
                                
                                post["Comments"] = []
                                post["CommentProfiles"] = []
                                
                                post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                                    
                                    if error == nil {
                                        
                                        print("success")
                                        
                                    } else {
                                        print("error")
                                    }
                                    
                                })
                            }
                        }
                        
                    }
                } else {
                    print(error)
                }
                self.loading = false
                
            }
        }
        
    }
    
    func updateInfo() {
        
        self.Image.sd_setImageWithURL(NSURL(string: imageUrl), placeholderImage: UIImage(named: "Background"))
        self.ProfilePicture.sd_setImageWithURL(NSURL(string: profilePictureUrl))
    }
    
    
    
    func addCloseSwipe() {
        
        let closeSwipe: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "closeMenu:")
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(closeSwipe)
        
    }
    
    func closeMenu(sender: UIPanGestureRecognizer) {
        
        var initialShit: CGFloat = CGFloat()
        let translation = sender.translationInView(view)
        
        
        switch sender.state {
            
        case .Began:
            initialShit = translation.x
            
            
        case .Ended:
            
            if translation.x < initialShit {
                
                rootController?.toggleComments({ (Bool) -> () in
                    self.view.endEditing(true)
                    
                    guard let actualController = self.rootController else {return}
                    actualController.mainController?.commentsOpened = false
                    
                    self.CommentText.text = ""
                    self.commentIcon.alpha = 1
                    self.comments.removeAll()
                    self.CommentTableView.reloadData()
                })
                
            }
            
        default:
            break
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
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60.0
        
        cell.selectionStyle = .None
        
        cell.WorkingLabel.text = comments[indexPath.row]
        
        cell.CommentProfile.sd_setImageWithURL(NSURL(string: profilePictures[indexPath.row]))
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.commentIcon.alpha = 0
            
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if CommentText.text == "" {
            
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.commentIcon.alpha = 1
                
            }
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
