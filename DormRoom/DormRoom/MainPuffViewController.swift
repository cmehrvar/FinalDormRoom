////
//  MainPuffViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class MainPuffViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootViewController?
    
    var myTableView = UITableView()
    
    var user = PFUser.currentUser()
    
    let dormroomurl = "https://s3.amazonaws.com/dormroombucket/"
    let placeholderImage = UIImage(named: "Background")
    
    var loading = false
    var commentsOpened = false
    var menuOpened = false
    
    var theBool: Bool = Bool()
    var myTimer: NSTimer = NSTimer()
    
    var imageUrls = [String]()
    var profilePictureURLS = [String]()
    var universityNames = [String]()
    var captions = [String]()
    var likes = [Int]()
    var dislikes = [Int]()
    var usernames = [String]()
    var objectId = [String]()
    var comments = [[String]]()
    var commentsNil = [Bool]()
    var usersBlocked = [[String]]()
    var imageDates = [NSDate]()
    var isImage = [Bool]()
    var videoUrls = [String]()
    
    let brock = UIImage(named: "Brock"), calgary = UIImage(named: "Calgary"), carlton = UIImage(named: "Carleton"), dal = UIImage(named: "Dalhousie"), laurier = UIImage(named: "Laurier"), mcgill = UIImage(named: "McGill"), mac = UIImage(named: "Mac"), mun = UIImage(named: "Mun"), ottawa = UIImage(named: "Ottawa"), queens = UIImage(named: "Queens"), ryerson = UIImage(named: "Ryerson"), ubc = UIImage(named: "UBC"), uoft = UIImage(named: "UofT"), western = UIImage(named: "Western"), york = UIImage(named: "York"), other = UIImage(named: "OtherUni")
    
    var feed = String()
    var ranking = String()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        if user?["firstTime"] as! Bool == true {
            
            rootController?.toggleTakePuff({ (complete) -> () in
                
                guard let actualController = self.rootController else {return}
                actualController.takePuffController?.feed = self.feed
                
                self.user?["firstTime"] = false
                self.user?.saveEventually()
                
            })
        }
        
        initializeFeeds()
        addScrollToTop()
        addRefresh()
        addRecognizers()
        loadFromParse { (complete) -> Void in
            print("parse loaded")
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    func addRecognizers() {
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        ImageBlur.userInteractionEnabled = true
        ImageBlur.addGestureRecognizer(tapRecognizer)
        
    }
    
    func dismissKeyboard() {
        
        ///////////////////////////////////////////////////////////////////////////////
        
        guard let actualController = rootController else {return}
        actualController.commentsController?.view.endEditing(true)
        
        guard let isUploading: Bool = actualController.commentsController?.isUploading else {return}
        guard let isTyping: Bool = actualController.commentsController?.textIsEditing else {return}
        
        print(isTyping)
        
        if commentsOpened && isTyping != true {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.ImageBlur.alpha = 0
                
            })
            
            rootController?.toggleComments({ (Bool) -> () in
                
                self.commentsOpened = false
                
                self.myTableView.scrollEnabled = true
                
                actualController.commentsController?.view.endEditing(true)
                
                if actualController.commentsController?.isImage == false {
                    actualController.commentsController?.player.pause()
                    actualController.commentsController?.playerLayer.removeFromSuperlayer()
                }
                
                
                if !isUploading {
                    actualController.commentsController?.CommentText.text = ""
                }
                actualController.commentsController?.commentIcon.alpha = 1
                actualController.commentsController?.comments.removeAll()
                actualController.commentsController?.CommentTableView.reloadData()
                actualController.commentsController?.Image.image = nil
                
            })
        }
        
        if menuOpened {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.ImageBlur.alpha = 0
                
            })
            
            rootController?.toggleMenu({ (Bool) -> () in
                
                self.menuOpened = false
            })
        }
        
    }
    
    
    //Outlets
    @IBOutlet weak var PuffTableView: UITableView!
    @IBOutlet weak var TakeAPuffOutlet: UIView!
    @IBOutlet weak var WebViewOutlet: UIWebView!
    @IBOutlet weak var uploadOutlet: UIImageView!
    @IBOutlet weak var ProgressView: UIProgressView!
    @IBOutlet weak var ImageBlur: UIView!
    
    
    //Actions
    @IBAction func takePuffAction(sender: AnyObject) {
        
        guard let actualController = rootController else {return}
        
        actualController.takePuffController?.feed = feed
        //actualController.takePuffController?.feed = feed
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            actualController.takePuffController?.TakenPuffOutlet.image = nil
            //actualController.takePuffController?.TakenPuffOutlet.image = nil
            actualController.takePuffController?.CaptionOutlet.text = nil
            
            self.uploadOutlet.alpha = 0
            
        })
    }
    
    
    @IBAction func menuAction(sender: AnyObject) {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.ImageBlur.alpha = 1
        })
        
        rootController?.toggleMenu({ (Bool) -> () in
            print("menu opened")
            //self.myTableView.scrollEnabled = false
            self.menuOpened = true
        })
    }
    
    
    //Functions
    func funcToCallWhenStartLoadingYourWebview() {
        ProgressView.progress = 0.0
        ProgressView.alpha = 1
        theBool = false
        myTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
    }
    
    func funcToCallCalledWhenUIWebViewFinishesLoading() {
        self.theBool = true
        ProgressView.alpha = 0
    }
    
    func timerCallback() {
        if theBool == true {
            if ProgressView.progress >= 1 {
                ProgressView.hidden = true
                
                myTimer.invalidate()
                
            } else {
                ProgressView.progress += 0.1
            }
        } else {
            ProgressView.progress += 0.05
            if ProgressView.progress >= 0.95 {
                ProgressView.progress = 0.95
            }
        }
    }
    
    
    func addScrollToTop() {
        let tapScrollToTop: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "scrollToTop")
        self.navigationItem.titleView?.userInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(tapScrollToTop)
        
    }
    
    func scrollToTop() {
        myTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        
        var cells: [AnyObject] = [AnyObject]()
        for var j = 0; j < myTableView.numberOfSections; ++j {
            for var i = 0; i < myTableView.numberOfRowsInSection(j); ++i {
                
                if let actualCell = myTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: j)) {
                    cells.append(actualCell)
                }
            }
        }
        
        for cell in cells {
            
            guard let actualCell: VideoTableViewCell = cell as? VideoTableViewCell else {return}
            actualCell.player.pause()
            
        }
        
    }
    
    
    func initializeFeeds() {
        
        feed = "CanadaPuff"
        ranking = "createdAt"
        
        if feed == "CanadaPuff" {
            TakeAPuffOutlet.alpha = 1
        } else if feed != user?["universityName"] as! String {
            TakeAPuffOutlet.alpha = 0
        } else {
            TakeAPuffOutlet.alpha = 1
        }
    }
    
    
    func addRefresh() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Keep on Puffin'")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func refresh(sender: AnyObject) {
        
        loadFromParse { () -> Void in
            print("parse loaded")
        }
        
        refreshControl.endRefreshing()
    }
    
    
    func loadFromParse(complete: () -> Void) {
        
        let query = PFQuery(className: "CanadaPuff")
        query.orderByDescending(ranking)
        
        query.findObjectsInBackgroundWithBlock { (puffs: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if !self.loading{
                    
                    self.loading = true
                    
                    self.imageUrls.removeAll()
                    self.profilePictureURLS.removeAll()
                    self.likes.removeAll()
                    self.dislikes.removeAll()
                    self.captions.removeAll()
                    self.universityNames.removeAll()
                    self.usernames.removeAll()
                    self.objectId.removeAll()
                    self.comments.removeAll()
                    self.commentsNil.removeAll()
                    self.imageDates.removeAll()
                    self.isImage.removeAll()
                    self.videoUrls.removeAll()
                    
                    if let puffs = puffs {
                        
                        for puff in puffs {
                            
                            if puff["Deleted"] == nil {
                                puff["Deleted"] = false
                            }
                            
                            if puff["VideoUrl"] == nil {
                                puff["VideoUrl"] = ""
                            }
                            
                            
                            if puff["IsImage"] == nil {
                                puff["IsImage"] = true
                            }
                            
                            if puff["Deleted"] as! Bool != true {
                                
                                let blockedUsers = self.user?["blockedPuffs"] as! [String]
                                var puffBlocked = false
                                
                                for blockedUser in blockedUsers {
                                    
                                    if puff["Username"] as! String == blockedUser {
                                        puffBlocked = true
                                    }
                                }
                                
                                if !puffBlocked {
                                    
                                    if self.feed != "CanadaPuff" {
                                        
                                        if puff["UniversityName"] as! String == self.feed {
                                            
                                            self.imageUrls.append(puff["ImageUrl"] as! String)
                                            self.profilePictureURLS.append(puff["ProfilePictureUrl"] as! String)
                                            self.captions.append(puff["Caption"] as! String)
                                            self.likes.append(puff["Like"] as! Int)
                                            self.dislikes.append(puff["Dislike"] as! Int)
                                            self.universityNames.append(puff["UniversityName"] as! String)
                                            self.usernames.append(puff["Username"] as! String)
                                            self.isImage.append(puff["IsImage"] as! Bool)
                                            self.videoUrls.append(puff["VideoUrl"] as! String)
                                            
                                            if let actualDate = puff.createdAt {
                                                self.imageDates.append(actualDate)
                                            }
                                            
                                            if puff["Comments"] == nil {
                                                self.commentsNil.append(true)
                                                self.comments.append([])
                                            } else {
                                                self.commentsNil.append(false)
                                                self.comments.append(puff["Comments"] as! [String])
                                            }
                                            
                                            
                                            if let actualId = puff.objectId {
                                                self.objectId.append(actualId)
                                            }
                                        }
                                        
                                    }
                                    else {
                                        
                                        self.imageUrls.append(puff["ImageUrl"] as! String)
                                        self.profilePictureURLS.append(puff["ProfilePictureUrl"] as! String)
                                        self.captions.append(puff["Caption"] as! String)
                                        self.likes.append(puff["Like"] as! Int)
                                        self.dislikes.append(puff["Dislike"] as! Int)
                                        self.universityNames.append(puff["UniversityName"] as! String)
                                        self.usernames.append(puff["Username"] as! String)
                                        self.isImage.append(puff["IsImage"] as! Bool)
                                        self.videoUrls.append(puff["VideoUrl"] as! String)
                                        
                                        if let actualDate = puff.createdAt {
                                            self.imageDates.append(actualDate)
                                        }
                                        
                                        if puff["Comments"] == nil {
                                            self.commentsNil.append(true)
                                            self.comments.append([])
                                        } else {
                                            self.commentsNil.append(false)
                                            self.comments.append(puff["Comments"] as! [String])
                                        }
                                        
                                        
                                        if let actualId = puff.objectId {
                                            self.objectId.append(actualId)
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                    
                    self.PuffTableView.reloadData()
                    print(self.imageUrls)
                    self.loading = false
                }
            } else {
                
                print("\(error)")
                
            }
        }
    }
    
    
    func loadWebsite() {
        
        guard let url = NSURL(string: "http://www.dormroomnetwork.com/trending.html") else {return}
        WebViewOutlet.loadRequest(NSURLRequest(URL: url))
        
    }
    
    func callCamera() -> UIImagePickerController {
        
        let cameraProfile = UIImagePickerController()
        cameraProfile.delegate = self
        
        cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
        cameraProfile.allowsEditing = false
        
        return cameraProfile
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        guard let actualRootController = rootController else {return}
        
        actualRootController.takePuffController?.TakenPuffOutlet.image = image
        
        actualRootController.takePuffController?.feed = feed
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            print("take puff toggled open")
            
        })
    }
    
    
    
    //TableView shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        myTableView = tableView
        
        let likedObjects: [String] = user?["liked"] as! [String]
        
        let date: NSDate = imageDates[indexPath.row]
        
        tableView.decelerationRate = 0.01
        
        tableView.addSubview(refreshControl)
        
        if isImage[indexPath.row] {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("PuffCell", forIndexPath: indexPath) as! PuffTableViewCell
            
            cell.selectionStyle = .None
            
            cell.objectId = objectId[indexPath.row]
            
            cell.like = likes[indexPath.row]
            
            cell.dislike = dislikes[indexPath.row]
            
            cell.timePosted.text = timeAgoSince(date)
            
            
            cell.ImageOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + imageUrls[indexPath.row])), placeholderImage: placeholderImage) { (image, error, cache, url) -> Void in
                
                if error == nil {
                    cell.SwipeViewOutlet.image = image
                }
            }
            
            cell.UsernameOutlet.text = "@" + usernames[indexPath.row]
            
            cell.ProfileOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + profilePictureURLS[indexPath.row])))
            
            var liked = false
            
            for likedObject in likedObjects {
                
                if likedObject == objectId[indexPath.row] {
                    liked = true
                }
            }
            
            if !liked {
                
                cell.LikeButtonOutlet.image = UIImage(named: "ThumbsUp")
                cell.likeView.userInteractionEnabled = true
                
                cell.DislikeButtonOutlet.image = UIImage(named: "ThumbsDown")
                cell.likeView.userInteractionEnabled = true
                
                
            } else {
                
                cell.LikeButtonOutlet.image = nil
                cell.likeView.userInteractionEnabled = false
                
                cell.DislikeButtonOutlet.image = nil
                cell.likeView.userInteractionEnabled = false
                
            }
            
            
            switch universityNames[indexPath.row] {
                
            case "Brock":
                cell.UniversityOutlet.image = brock
                
            case "Calgary":
                cell.UniversityOutlet.image = calgary
                
            case "Carlton":
                cell.UniversityOutlet.image = carlton
                
            case "Dalhousie":
                cell.UniversityOutlet.image = dal
                
            case "Laurier":
                cell.UniversityOutlet.image = laurier
                
            case "McGill":
                cell.UniversityOutlet.image = mcgill
                
            case "Mac":
                cell.UniversityOutlet.image = mac
                
            case "Mun":
                cell.UniversityOutlet.image = mun
                
            case "Ottawa":
                cell.UniversityOutlet.image = ottawa
                
            case "Queens":
                cell.UniversityOutlet.image = queens
                
            case "Ryerson":
                cell.UniversityOutlet.image = ryerson
                
            case "UBC":
                cell.UniversityOutlet.image = ubc
                
            case "UofT":
                cell.UniversityOutlet.image = uoft
                
            case "Western":
                cell.UniversityOutlet.image = western
                
            case "York":
                cell.UniversityOutlet.image = york
                
            case "OtherUni":
                cell.UniversityOutlet.image = other
                
            default:
                break
                
            }
            
            cell.LikeOutlet.text = "\(likes[indexPath.row])"
            
            cell.DislikeOutlet.text = "\(dislikes[indexPath.row])"
            
            cell.CaptionOutlet.text = captions[indexPath.row]
            
            
            if commentsNil[indexPath.row] == true {
                cell.CommentNumber.text = "0"
            } else {
                cell.CommentNumber.text = "\(comments[indexPath.row].count)"
            }
            
            cell.feed = feed
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoTableViewCell
            
            cell.selectionStyle = .None
            
            cell.objectId = objectId[indexPath.row]
            
            cell.like = likes[indexPath.row]
            
            cell.dislike = dislikes[indexPath.row]
            
            cell.timePosted.text = timeAgoSince(date)
            
            cell.playVideo(videoUrls[indexPath.row])
            
            /*
            for realCell in cells {
            if realCell = cell {
            cell.playVideo(videoUrls[indexPath.row])
            }
            }
            */
            
            
            cell.UsernameOutlet.text = "@" + usernames[indexPath.row]
            
            cell.ProfileOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + profilePictureURLS[indexPath.row])))
            
            var liked = false
            
            for likedObject in likedObjects {
                
                if likedObject == objectId[indexPath.row] {
                    liked = true
                }
            }
            
            if !liked {
                
                cell.LikeButtonOutlet.image = UIImage(named: "ThumbsUp")
                cell.likeView.userInteractionEnabled = true
                
                cell.DislikeButtonOutlet.image = UIImage(named: "ThumbsDown")
                cell.likeView.userInteractionEnabled = true
                
                
            } else {
                
                cell.LikeButtonOutlet.image = nil
                cell.likeView.userInteractionEnabled = false
                
                cell.DislikeButtonOutlet.image = nil
                cell.likeView.userInteractionEnabled = false
                
            }
            
            
            switch universityNames[indexPath.row] {
                
            case "Brock":
                cell.UniversityOutlet.image = brock
                
            case "Calgary":
                cell.UniversityOutlet.image = calgary
                
            case "Carlton":
                cell.UniversityOutlet.image = carlton
                
            case "Dalhousie":
                cell.UniversityOutlet.image = dal
                
            case "Laurier":
                cell.UniversityOutlet.image = laurier
                
            case "McGill":
                cell.UniversityOutlet.image = mcgill
                
            case "Mac":
                cell.UniversityOutlet.image = mac
                
            case "Mun":
                cell.UniversityOutlet.image = mun
                
            case "Ottawa":
                cell.UniversityOutlet.image = ottawa
                
            case "Queens":
                cell.UniversityOutlet.image = queens
                
            case "Ryerson":
                cell.UniversityOutlet.image = ryerson
                
            case "UBC":
                cell.UniversityOutlet.image = ubc
                
            case "UofT":
                cell.UniversityOutlet.image = uoft
                
            case "Western":
                cell.UniversityOutlet.image = western
                
            case "York":
                cell.UniversityOutlet.image = york
                
            default:
                break
                
            }
            
            cell.LikeOutlet.text = "\(likes[indexPath.row])"
            
            cell.DislikeOutlet.text = "\(dislikes[indexPath.row])"
            
            cell.CaptionOutlet.text = captions[indexPath.row]
            
            
            if commentsNil[indexPath.row] == true {
                cell.CommentNumber.text = "0"
            } else {
                cell.CommentNumber.text = "\(comments[indexPath.row].count)"
            }
            
            cell.feed = feed
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !commentsOpened {
            
            guard let actualController = rootController else {return}
            
            if !isImage[indexPath.row] {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! VideoTableViewCell
                cell.player.pause()
            }
            
            
            if isImage[indexPath.row] {
            actualController.commentsController?.imageUrl = dormroomurl + imageUrls[indexPath.row]
            actualController.commentsController?.isImage = true
            } else {
                
                actualController.commentsController?.isImage = false
                actualController.commentsController?.playVideo(videoUrls[indexPath.row])
            }
            
            actualController.commentsController?.profilePictureUrl = dormroomurl + profilePictureURLS[indexPath.row]
            
            actualController.commentsController?.usernameString = usernames[indexPath.row]
            
            actualController.commentsController?.updateInfo()
            
            switch universityNames[indexPath.row] {
                
            case "Brock":
                actualController.commentsController?.University.image = brock
                
            case "Calgary":
                actualController.commentsController?.University.image = calgary
                
            case "Carlton":
                actualController.commentsController?.University.image = carlton
                
            case "Dalhousie":
                actualController.commentsController?.University.image = dal
                
            case "Laurier":
                actualController.commentsController?.University.image = laurier
                
            case "McGill":
                actualController.commentsController?.University.image = mcgill
                
            case "Mac":
                actualController.commentsController?.University.image = mac
                
            case "Mun":
                actualController.commentsController?.University.image = mun
                
            case "Ottawa":
                actualController.commentsController?.University.image = ottawa
                
            case "Queens":
                actualController.commentsController?.University.image = queens
                
            case "Ryerson":
                actualController.commentsController?.University.image = ryerson
                
            case "UBC":
                actualController.commentsController?.University.image = ubc
                
            case "UofT":
                actualController.commentsController?.University.image = uoft
                
            case "Western":
                actualController.commentsController?.University.image = western
                
            case "York":
                actualController.commentsController?.University.image = york
                
            case "OtherUni":
                actualController.commentsController?.University.image = other
                
            default:
                break
                
            }
            
            actualController.commentsController?.Username.text = "@" + usernames[indexPath.row]
            
            actualController.commentsController?.objectId = objectId[indexPath.row]
            
            actualController.commentsController?.feed = feed
            
            
            
            actualController.commentsController?.loadFromParse()
            
            actualController.commentsController?.view.endEditing(true)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.ImageBlur.alpha = 1
            })
            
            rootController?.toggleComments({ (Bool) -> () in
                
                
                
                print("comments toggled")
                
            })
            
            commentsOpened = true
            
        } else {
            
            guard let actualController = rootController else {return}
            actualController.commentsController?.view.endEditing(true)
            
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        funcToCallCalledWhenUIWebViewFinishesLoading()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if request.URL?.absoluteString == "http://www.dormroomnetwork.com/trending.html" {
            return true
        } else {
            return false
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        var cells: [AnyObject] = [AnyObject]()
        for var j = 0; j < myTableView.numberOfSections; ++j {
            for var i = 0; i < myTableView.numberOfRowsInSection(j); ++i {
                if !isImage[i] {
                    if let actualCell = myTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: j)) {
                        cells.append(actualCell)
                    }
                }
            }
        }
        
        for cell in cells {
            
            guard let actualCell: VideoTableViewCell = cell as? VideoTableViewCell else { print("not video cell")
                return}
            actualCell.player.pause()
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SDWebImageManager.sharedManager().imageCache.clearDisk()
        SDWebImageManager.sharedManager().imageCache.clearMemory()
        
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
