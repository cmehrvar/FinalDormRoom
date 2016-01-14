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
    var dates = [NSDate]()
    var objectId = String()
    var feed = String()
    var usernameString = String()
    
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
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var BlockReportOutlet: UILabel!
    
    
    //Actions
    @IBAction func yesReport(sender: AnyObject) {
        
        report()
        
    }
    
    
    @IBAction func noReport(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.reportView.alpha = 0
            
        }
    }
    
    
    @IBAction func report(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            if self.usernameString != self.user?.username {
                
                self.BlockReportOutlet.text = "Report & Block User?"
                
            } else {
                self.BlockReportOutlet.text = "Delete?"
            }
            
            self.reportView.alpha = 1
            
        }
    }
    
    
    
    
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
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            guard let actualController = self.rootController else {return}
            actualController.mainController?.ImageBlur.alpha = 0
            self.reportView.alpha = 0
        })
        
        rootController?.toggleComments({ (Bool) -> () in
            
            guard let actualController = self.rootController else {return}
            
            actualController.mainController?.myTableView.scrollEnabled = true
            
            actualController.mainController?.commentsOpened = false
            
            self.view.endEditing(true)
            
            if !self.isUploading {
                self.CommentText.text = ""
            }
            
            self.textIsEditing = false
            self.commentIcon.alpha = 1
            self.comments.removeAll()
            self.CommentTableView.reloadData()
            
        })
    }
    
    //Functions
    func report() {
        
        if usernameString != user?.username {
            
            
            var blockedPuffs = [String]()
            
            do {
                try user?.fetch()
            } catch let error {
                print(error)
            }
            
            blockedPuffs = user?["blockedPuffs"] as! [String]
            
            user?["blockedPuffs"] = [usernameString] + blockedPuffs
            
            user?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    do {
                        try self.user?.fetch()
                    } catch let error {
                        print(error)
                    }
                    
                    }) { (Bool) -> Void in
                        self.reportView.alpha = 0
                        self.rootController?.mainController?.ImageBlur.alpha = 0
                        self.rootController?.toggleComments({ (Bool) -> () in
                            
                            guard let actualController = self.rootController else {return}
                            
                            actualController.mainController?.myTableView.scrollEnabled = true
                            
                            actualController.mainController?.commentsOpened = false
                            
                            actualController.mainController?.loadFromParse({ () -> Void in
                                
                            })
                            
                            self.view.endEditing(true)
                            
                            if !self.isUploading {
                                self.CommentText.text = ""
                            }
                            self.commentIcon.alpha = 1
                            self.comments.removeAll()
                            self.CommentTableView.reloadData()
                            
                        })

                }
                
                
            })
        } else {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.reportView.alpha = 0
            })
            
            let alertController = UIAlertController(title: "So...", message: "You wanna delete this?", preferredStyle:  UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                
                let query = PFQuery(className: self.feed)
                query.getObjectInBackgroundWithId(self.objectId, block: { (post: PFObject?, error: NSError?) -> Void in
                    
                    post?["Deleted"] = true
                    post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                        
                        self.rootController?.toggleComments({ (Bool) -> () in
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.rootController?.mainController?.ImageBlur.alpha = 0
                            })
                            self.rootController?.mainController?.loadFromParse({ () -> Void in
                                
                            })
                        })
                    })
                })
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
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
                    self.uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
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
                
                let date = NSDate()
                
                self.comments = post["Comments"] as! [String]
                self.profilePictures = post["CommentProfiles"] as! [String]
                self.dates = post["CommentDates"] as! [NSDate]
                
                post["Comments"] = [self.CommentText.text] + self.comments
                post["CommentProfiles"] = [self.uploadProfileUrl] + self.profilePictures
                post["CommentDates"] = [date] + self.dates
                
                post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        self.CommentText.text = ""
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.commentIcon.alpha = 1
                            self.UploadIcon.alpha = 0
                            self.isUploading = false
                            self.uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
                            self.rootController?.mainController?.loadFromParse({ () -> Void in
                                
                            })
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
                            self.uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
                            
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
                        self.dates = post?["CommentDates"] as! [NSDate]
                        
                        self.CommentTableView.reloadData()
                        
                    } else {
                        
                        
                        let query = PFQuery(className: self.feed)
                        query.getObjectInBackgroundWithId(self.objectId) { (post: PFObject?, error: NSError?) -> Void in
                            
                            if error != nil {
                                print(error)
                            } else if let post = post {
                                
                                post["Comments"] = []
                                post["CommentProfiles"] = []
                                post["CommentDates"] = []
                                
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
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    guard let actualController = self.rootController else {return}
                    actualController.mainController?.ImageBlur.alpha = 0
                    self.reportView.alpha = 0
                })
                
                rootController?.toggleComments({ (Bool) -> () in
                    self.view.endEditing(true)
                    
                    guard let actualController = self.rootController else {return}
                    actualController.mainController?.commentsOpened = false
                    
                    actualController.mainController?.myTableView.scrollEnabled = true
                    
                    if !self.isUploading {
                        self.CommentText.text = ""
                    }
                    self.commentIcon.alpha = 1
                    self.textIsEditing = false
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
        cell.TimeLabel.text = timeAgoSince(dates[indexPath.row])
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            self.textIsEditing = true
            self.commentIcon.alpha = 0
            
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if CommentText.text == "" {
            
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.textIsEditing = false
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
