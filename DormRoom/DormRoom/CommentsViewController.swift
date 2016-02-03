//
//  CommentsViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-19.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var rootController: MainRootViewController?
    
    var comments = [String]()
    var checkedComments = [String]()
    var profilePictures = [String]()
    var checkedProfilePictures = [String]()
    var dates = [NSDate]()
    var checkedDates = [NSDate]()
    var usernames = [String]()
    var checkedUsernames = [String]()
    var universities = [String]()
    var checkedUniversities = [String]()
    var votes = [Int]()
    var checkedVotes = [Int]()
    var commentIds = [String]()
    var checkedCommentIds = [String]()
    var isPhoto = [Bool]()
    var checkedIsPhoto = [Bool]()
    var commentPhotos = [String]()
    var checkedCommentPhotos = [String]()
    var isDeleted = [Bool]()

    
    var dormroomUrl = "https://s3.amazonaws.com/dormroombucket/"
    
    var objectId = String()
    
    var textIsEditing = false
    
    let user = PFUser.currentUser()
    
    var isUploading = false
    
    var replyImage = UIImage()
    
    var imageUrl = String()
    var profilePictureUrl = String()
    var uploadProfileUrl = "https://s3.amazonaws.com/dormroombucket/"
    
    var isPhotoComment = false
    
    var loading = false
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "CommentsTitle"))
        
        CommentText.delegate = self
        PhotoText.delegate = self
        
        handleKeyboard()
        addTapGesture()
        addRefresh()
        // Do any additional setup after loading the view.
    }
    
    //Outlets
    @IBOutlet weak var CommentText: UITextView!
    @IBOutlet weak var CommentTableView: UITableView!
    @IBOutlet weak var UploadIcon: UIImageView!
    @IBOutlet weak var CommentPhoto: UIImageView!
    @IBOutlet weak var PhotoText: UITextView!
    @IBOutlet weak var textView: UIView!
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var TableViewConstraint: NSLayoutConstraint!
    
    
    //Actions
    
    
    
    
    
    
    @IBAction func callCamera(sender: AnyObject) {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        let alertController = UIAlertController(title: "Smile!", message: "Take a pic or choose from gallery?", preferredStyle:  UIAlertControllerStyle.Alert)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
            }
            
            self.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
            
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(cameraProfile, animated: true, completion: nil)
            
        }))
        
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
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
        
        print("hide tapped")
        
        view.endEditing(true)
        
        comments.removeAll()
        profilePictures.removeAll()
        dates.removeAll()
        usernames.removeAll()
        universities.removeAll()
        votes.removeAll()
        commentIds.removeAll()
        isPhoto.removeAll()
        commentPhotos.removeAll()
        isDeleted.removeAll()
        checkedCommentIds.removeAll()
        checkedCommentPhotos.removeAll()
        checkedComments.removeAll()
        checkedDates.removeAll()
        checkedIsPhoto.removeAll()
        checkedProfilePictures.removeAll()
        checkedUniversities.removeAll()
        checkedUsernames.removeAll()
        
        discardPhoto()
        
        CommentTableView.reloadData()
        
        rootController?.toggleComments({ (Bool) -> () in
            print("Comments Closed")
        })
        
    }
    
    @IBAction func postPhoto(sender: AnyObject) {
        
        view.endEditing(true)
        
        if let actualImage = CommentPhoto.image {
            uploadToAWS(actualImage)
        }
    }
    
    @IBAction func discardPhoto(sender: AnyObject) {
        
        discardPhoto()
    }
    
    
    //Functions
    func uploadToAWS(image: UIImage) {
        
        let uploadRequest = imageUploadRequest(image)
        
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        transferManager.upload(uploadRequest).continueWithBlock { (task) -> AnyObject? in
            
            if task.error == nil {
                
                print("successful image upload")
                
                self.uploadProfilePicture()
                ///////// DO SOMETHING
                
                
            } else {
                print("error uploading: \(task.error)")
                
                let alertController = UIAlertController(title: "Shit...", message: "Error Uploading", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            return nil
        }
    }
    
    func imageUploadRequest(image: UIImage) -> AWSS3TransferManagerUploadRequest {
        
        let fileName = NSProcessInfo.processInfo().globallyUniqueString.stringByAppendingString(".jpeg")
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("upload").URLByAppendingPathComponent(fileName)
        let filePath = fileURL.path!
        
        let imageData = UIImageJPEGRepresentation(image, 0.25)
        
        imageData?.writeToFile(filePath, atomically: true)
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.body = fileURL
        uploadRequest.key = fileName
        uploadRequest.bucket = "dormroombucket"
        
        if let key = uploadRequest.key {
            imageUrl = key
        }
        
        return uploadRequest
        
    }
    
    func discardPhoto() {
        
        TableViewConstraint.constant = 0
        isPhotoComment = false
        
        PhotoText.text = "Comment Here"
        CommentPhoto.image = nil
        
        photoView.alpha = 0
        textView.alpha = 1
        
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
                
                if post["IsCommentDeleted"] == nil {
                    self.isDeleted = []
                } else {
                    self.isPhoto = post["IsCommentDeleted"] as! [Bool]
                }

                
                if post["CommentPhoto"] == nil {
                    self.commentPhotos = []
                } else {
                    self.commentPhotos = post["CommentPhoto"] as! [String]
                }
                
                if post["IsPhotoComment"] == nil {
                    self.isPhoto = []
                } else {
                    self.isPhoto = post["IsPhotoComment"] as! [Bool]
                }
                
                if post["CommentIds"] == nil {
                    self.commentIds = []
                } else {
                    self.commentIds = post["CommentIds"] as! [String]
                }
                
                
                post["NewCommentProfiles"] = [self.uploadProfileUrl] + self.profilePictures
                post["NewCommentDates"] = [date] + self.dates
                post["NewCommentUniversities"] = [self.user?["universityName"] as! String] + self.universities
                post["CommentIds"] = [fileName] + self.commentIds
                post["IsCommentDeleted"] = [false] + self.isDeleted
                
                if self.isPhotoComment {
                    post["NewComments"] = [self.PhotoText.text] + self.comments
                    post["CommentPhoto"] = [self.dormroomUrl + self.imageUrl] + self.commentPhotos
                } else {
                    post["CommentPhoto"] = [""] + self.commentPhotos
                    post["NewComments"] = [self.CommentText.text] + self.comments
                }
                
                post["IsPhotoComment"] = [self.isPhotoComment] + self.isPhoto
                
                
                if let actualUsername = self.user?.username {
                    post["NewCommentUsernames"] = [actualUsername] + self.usernames
                }
                
                post["NewCommentVotes"] = [0] + self.votes
                
                post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        print("comment saved")
                        
                        self.CommentText.text = ""
                        self.discardPhoto()
                        
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
                    self.isPhoto.removeAll()
                    self.commentPhotos.removeAll()
                    self.isDeleted.removeAll()
                    
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
                        
                        
                        if post?["CommentPhoto"] == nil {
                            self.commentPhotos = []
                        } else {
                            self.commentPhotos = post?["CommentPhoto"] as! [String]
                        }
                        
                        if post?["IsPhotoComment"] == nil {
                            self.isPhoto = []
                        } else {
                            self.isPhoto = post?["IsPhotoComment"] as! [Bool]
                        }
                        
                        if post?["IsCommentDeleted"] == nil {
                            self.isDeleted = []
                        } else {
                            self.isDeleted = post?["IsCommentDeleted"] as! [Bool]
                        }
                        
                        self.checkedUniversities.removeAll()
                        self.checkedComments.removeAll()
                        self.checkedProfilePictures.removeAll()
                        self.checkedUsernames.removeAll()
                        self.checkedDates.removeAll()
                        self.checkedVotes.removeAll()
                        self.checkedIsPhoto.removeAll()
                        self.checkedCommentIds.removeAll()
                        self.checkedCommentPhotos.removeAll()
                        
                        var i = 0
                        
                        if post?["IsCommentDeleted"] != nil {
                            
                            for deleted in self.isDeleted {
                                
                                if !deleted {
                                    
                                    self.checkedComments.append(self.comments[i])
                                    self.checkedProfilePictures.append(self.profilePictures[i])
                                    self.checkedUsernames.append(self.usernames[i])
                                    self.checkedDates.append(self.dates[i])
                                    self.checkedVotes.append(self.votes[i])
                                    self.checkedIsPhoto.append(self.isPhoto[i])
                                    self.checkedCommentIds.append(self.commentIds[i])
                                    self.checkedCommentPhotos.append(self.commentPhotos[i])
                                    self.checkedUniversities.append(self.universities[i])
                                }
                                
                                i++
                            }

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
                        post?["IsPhotoComment"] = []
                        post?["CommentPhoto"] = []
                        post?["IsCommentDeleted"] = []
                        
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
        
        self.rootController?.mainController?.loadFromParse({ (Bool) -> () in
            
        })
    }
    
    func addTapGesture() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        textView.alpha = 0
        photoView.alpha = 1
        
        isPhotoComment = true
        TableViewConstraint.constant = 40
        
        CommentPhoto.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if checkedIsPhoto[indexPath.row] {
            return 125.0
        } else {
            return 100.0
        }
        
    }
    

    //TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.addSubview(refreshControl)

        if checkedIsPhoto[indexPath.row] {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentsPhotoCell", forIndexPath: indexPath) as! PhotoCommentCell
            
            cell.profileUrl = profilePictures[indexPath.row]
            cell.usernameVar = usernames[indexPath.row]
            cell.timePostedVar = timeAgoSince(dates[indexPath.row])
            
            cell.isDeleted = isDeleted
                        
            var hasBeenVotedOn = false
            
            var commentsVotedOn = [String]()
            
            if checkedUsernames[indexPath.row] == user?.username {
                
                cell.DeleteOutlet.alpha = 1
                
            } else {
                
                cell.DeleteOutlet.alpha = 0
                
            }

            if user?["votes"] == nil {
                commentsVotedOn = []
            } else {
                commentsVotedOn = user?["votes"] as! [String]
            }
            
            for commentVotedOn in commentsVotedOn {
                
                if commentVotedOn == checkedCommentIds[indexPath.row] {
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
            
            cell.Comment.text = checkedComments[indexPath.row]
            cell.TimePosted.text = timeAgoSince(checkedDates[indexPath.row])
            cell.ProfilePicture.sd_setImageWithURL(NSURL(string: checkedProfilePictures[indexPath.row]))
            cell.Username.text = checkedUsernames[indexPath.row] + ","
            cell.photoComment.sd_setImageWithURL(NSURL(string: checkedCommentPhotos[indexPath.row]))
            cell.photoUrl = checkedCommentPhotos[indexPath.row]
            
            if checkedVotes[indexPath.row] > 0 {
                
                cell.VoteCount.text = "\(checkedVotes[indexPath.row])"
                cell.plusMinusIcon.image = UIImage(named: "plus")
                
            } else if checkedVotes[indexPath.row] == 0 {
                
                cell.plusMinusIcon.image = nil
                cell.VoteCount.text = "\(checkedVotes[indexPath.row])"
                
            } else if checkedVotes[indexPath.row] < 0 {
                
                cell.plusMinusIcon.image = UIImage(named: "minus")
                let positiveVotes = -(checkedVotes[indexPath.row])
                cell.VoteCount.text = "\(positiveVotes)"
                
            }
            
            cell.commentViewController = self
            cell.commentId = checkedCommentIds[indexPath.row]
            
            cell.votes = checkedVotes
            cell.indexPath = indexPath.row
            cell.objectId = objectId
            
            
            switch checkedUniversities[indexPath.row] {
                
            case "Brock":
                cell.UniversityName.text = "Brock Univeristy"
                cell.uniVar = "Brock Univeristy"
                
            case "Calgary":
                cell.UniversityName.text = "University of Calgary"
                cell.uniVar = "University of Calgary"
                
            case "Carlton":
                cell.UniversityName.text = "Carlton University"
                cell.uniVar = "Carlton University"
                
            case "Dalhousie":
                cell.UniversityName.text = "Dalhousie University"
                cell.uniVar = "Dalhousie University"
                
            case "Laurier":
                cell.UniversityName.text = "Wilfred Laurier University"
                cell.uniVar = "Wilfred Laurier University"
                
            case "McGill":
                cell.UniversityName.text = "McGill University"
                cell.uniVar = "McGill University"
                
            case "Mac":
                cell.UniversityName.text = "McMaster University"
                cell.uniVar = "McMaster University"
                
            case "Mun":
                cell.UniversityName.text = "Memorial University"
                cell.uniVar = "Memorial University"
                
            case "Ottawa":
                cell.UniversityName.text = "University of Ottawa"
                cell.uniVar = "University of Ottawa"
                
            case "Queens":
                cell.UniversityName.text = "Queens University"
                cell.uniVar = "Queens University"
                
            case "Ryerson":
                cell.UniversityName.text = "Ryerson University"
                cell.uniVar = "Ryerson University"
                
            case "UBC":
                cell.UniversityName.text = "University of British Colombia"
                cell.uniVar = "University of British Colombia"
                
            case "UofT":
                cell.UniversityName.text = "University of Toronto"
                cell.uniVar = "University of Toronto"
                
            case "Western":
                cell.UniversityName.text = "University of Western Ontario"
                cell.uniVar = "University of Western Ontario"
                
            case "York":
                cell.UniversityName.text = "York University"
                cell.uniVar = "York University"
                
            case "OtherUni":
                cell.UniversityName.text = "Other"
                cell.uniVar = "Other"
                
            default:
                break
                
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentsCell", forIndexPath: indexPath) as! CommentsCell
            
            var hasBeenVotedOn = false
            
            var commentsVotedOn = [String]()
            
            if user?["votes"] == nil {
                commentsVotedOn = []
            } else {
                commentsVotedOn = user?["votes"] as! [String]
            }
            
            for commentVotedOn in commentsVotedOn {
                
                if commentVotedOn == checkedCommentIds[indexPath.row] {
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
            
            cell.Comment.text = checkedComments[indexPath.row]
            cell.TimePosted.text = timeAgoSince(checkedDates[indexPath.row])
            cell.ProfilePicture.sd_setImageWithURL(NSURL(string: checkedProfilePictures[indexPath.row]))
            cell.Username.text = checkedUsernames[indexPath.row] + ","
            
            
            if checkedVotes[indexPath.row] > 0 {
                
                cell.VoteCount.text = "\(checkedVotes[indexPath.row])"
                cell.plusMinusIcon.image = UIImage(named: "plus")
                
            } else if checkedVotes[indexPath.row] == 0 {
                
                cell.plusMinusIcon.image = nil
                cell.VoteCount.text = "\(checkedVotes[indexPath.row])"
                
            } else if checkedVotes[indexPath.row] < 0 {
                
                cell.plusMinusIcon.image = UIImage(named: "minus")
                let positiveVotes = -(checkedVotes[indexPath.row])
                cell.VoteCount.text = "\(positiveVotes)"
                
            }
            
            cell.commentViewController = self
            cell.commentId = checkedCommentIds[indexPath.row]
            
            cell.votes = checkedVotes
            cell.indexPath = indexPath.row
            cell.objectId = objectId
            cell.isDeleted = isDeleted
            
            switch checkedUniversities[indexPath.row] {
                
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
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return checkedComments.count
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        print("began")
        
        if textView == CommentText {
            
            if CommentText.text == "Comment Here" {
                CommentText.text = ""
            }
            
            self.textIsEditing = true
            
        } else {
            
            if PhotoText.text == "Comment Here" {
                PhotoText.text = ""
            }
            
        }
        self.textIsEditing = true
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("ended")
        
        if textView == CommentText {
            
            if CommentText.text == "" {
                CommentText.text = "Comment Here"
            }
            
            
        } else {
            
            if PhotoText.text == "" {
                PhotoText.text = "Comment Here"
            }
            
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
