////
//  MainPuffViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation

class MainPuffViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    weak var rootController: MainRootViewController?
    
    
    var tapToTop = false
    
    
    var myTableView = UITableView()
    
    var user = PFUser.currentUser()
    
    var didClickPlay = false
    
    var wasVisible = false
    var index = 0
    
    let dormroomurl = "https://s3.amazonaws.com/dormroombucket/"
    let placeholderImage = UIImage(named: "Background")
    
    var videoPlayer: AVPlayer!
    var videoPlayerLayer: AVPlayerLayer!
    var videoPlayerItem: AVPlayerItem!
    
    var loading = false
    var commentsOpened = false
    var menuOpened = false
    
    var firstLoad = false
    
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
    var checkedComments = [[String]]()
    var deletedComments = [[Bool]]()
    
    var commentsNil = [Bool]()
    var usersBlocked = [[String]]()
    var imageDates = [NSDate]()
    var isImage = [Bool]()
    var videoUrls = [String]()
    
    var commentUsernames = [[String]]()
    var checkedUsernames = [[String]]()
    
    var asset = [AVURLAsset]()
    
    let brock = UIImage(named: "Brock"), calgary = UIImage(named: "Calgary"), carlton = UIImage(named: "Carleton"), dal = UIImage(named: "Dalhousie"), laurier = UIImage(named: "Laurier"), mcgill = UIImage(named: "McGill"), mac = UIImage(named: "Mac"), mun = UIImage(named: "Mun"), ottawa = UIImage(named: "Ottawa"), queens = UIImage(named: "Queens"), ryerson = UIImage(named: "Ryerson"), ubc = UIImage(named: "UBC"), uoft = UIImage(named: "UofT"), western = UIImage(named: "Western"), york = UIImage(named: "York"), other = UIImage(named: "OtherUni")
    
    var feed = String()
    var ranking = String()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        initializeFeeds()
        addScrollToTop()
        addRefresh()
        addRecognizers()
        loadFromParse { (Bool) -> () in
            print("parse loaded")
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    //Outlets
    @IBOutlet weak var PuffTableView: UITableView!
    @IBOutlet weak var TakeAPuffOutlet: UIView!
    @IBOutlet weak var WebViewOutlet: UIWebView!
    @IBOutlet weak var uploadOutlet: UIImageView!
    @IBOutlet weak var ProgressView: UIProgressView!
    @IBOutlet weak var ImageBlur: UIView!
    @IBOutlet weak var PlayPauseView: UIView!
    @IBOutlet weak var PlayPauseImage: UIImageView!
    
    
    
    //Actions
    @IBAction func takePuffAction(sender: AnyObject) {
        
        guard let actualController = rootController else {return}
        
        actualController.takePuffController?.feed = feed
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
            actualController.takePuffController?.TakenPuffOutlet.image = nil
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
            self.menuOpened = true
        })
    }
    
    
    //Functions
    func addRecognizers() {
        
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        ImageBlur.userInteractionEnabled = true
        ImageBlur.addGestureRecognizer(tapRecognizer)
        
        
        let playPauseRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "playPauseButtonAction")
        PlayPauseView.userInteractionEnabled = true
        PlayPauseView.addGestureRecognizer(playPauseRecognizer)
        
        
    }
    
    func dismissKeyboard() {
        
        if menuOpened {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.ImageBlur.alpha = 0
            })
            rootController?.toggleMenu({ (Bool) -> () in
                self.menuOpened = false
            })
        }
    }
    
    func playPauseButtonAction() {
        
        if !didClickPlay {
            
            if videoPlayer != nil {
                videoPlayer.play()
                
                let image = UIImage(named: "pauseIcon")
                
                PlayPauseImage.image = image
            }
            didClickPlay = !didClickPlay
            
        } else {
            
            if videoPlayer != nil {
                videoPlayer.pause()
                PlayPauseImage.image = UIImage(named: "playIcon")
            }
            
            didClickPlay = !didClickPlay
            
        }
    }
    
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
        
        tapToTop = true
        
        if !isImage[0] {
            
            index = 0
            wasVisible = true
            //myTableView.reloadData()
            
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
        self.refreshControl.attributedTitle = NSAttributedString(string: "More Student Posts...")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func refresh(sender: AnyObject) {
        
        loadFromParse { (Bool) -> () in
            print("loadCompleted")
        }
        
        refreshControl.endRefreshing()
    }
    
    func loadFromParse(complete: (Bool) -> ()) {
        
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
                    self.checkedComments.removeAll()
                    self.commentsNil.removeAll()
                    self.imageDates.removeAll()
                    self.isImage.removeAll()
                    self.videoUrls.removeAll()
                    self.commentUsernames.removeAll()
                    self.checkedUsernames.removeAll()
                    self.asset.removeAll()
                    self.deletedComments.removeAll()
                    
                    if let puffs = puffs {
                        
                        var mainIndex = 0
                        
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
                                            self.asset.append(AVURLAsset(URL: NSURL(string: "")!))
                                            self.checkedComments.append([])
                                            self.checkedUsernames.append([])
                                            
                                            
                                            if puff["NewCommentUsernames"] != nil {
                                                self.commentUsernames.append(puff["NewCommentUsernames"] as! [String])
                                            } else {
                                                self.commentUsernames.append([])
                                            }
                                            
                                            if let actualDate = puff.createdAt {
                                                self.imageDates.append(actualDate)
                                            }
                                            
                                            if puff["NewComments"] == nil {
                                                self.commentsNil.append(true)
                                                self.comments.append([])
                                            } else {
                                                self.commentsNil.append(false)
                                                self.comments.append(puff["NewComments"] as! [String])
                                            }
                                            
                                            if let actualId = puff.objectId {
                                                self.objectId.append(actualId)
                                            }
                                            
                                            
                                            
                                            if puff["IsCommentDeleted"] != nil {
                                                
                                                self.deletedComments.append(puff["IsCommentDeleted"] as! [Bool])
                                                
                                                var i = 0
                                                
                                                for deleted in self.deletedComments[mainIndex] {
                                                    
                                                    if !deleted {
                                                        
                                                        self.checkedComments[mainIndex].append(self.comments[mainIndex][i])
                                                        self.checkedUsernames[mainIndex].append(self.commentUsernames[mainIndex][i])
                                                        
                                                    }
                                                    
                                                    i++
                                                }
                                                
                                            } else {
                                                self.deletedComments.append([])
                                                self.checkedComments[mainIndex] = []
                                                self.checkedUsernames[mainIndex] = []
                                            }
                                            
                                            mainIndex++
                                            
                                        }
                                        
                                    } else {
                                        
                                        self.imageUrls.append(puff["ImageUrl"] as! String)
                                        self.profilePictureURLS.append(puff["ProfilePictureUrl"] as! String)
                                        self.captions.append(puff["Caption"] as! String)
                                        self.likes.append(puff["Like"] as! Int)
                                        self.dislikes.append(puff["Dislike"] as! Int)
                                        self.universityNames.append(puff["UniversityName"] as! String)
                                        self.usernames.append(puff["Username"] as! String)
                                        self.isImage.append(puff["IsImage"] as! Bool)
                                        self.videoUrls.append(puff["VideoUrl"] as! String)
                                        self.asset.append(AVURLAsset(URL: NSURL(string: "")!))
                                        self.checkedComments.append([])
                                        self.checkedUsernames.append([])
                                        
                                        if let actualDate = puff.createdAt {
                                            self.imageDates.append(actualDate)
                                        }
                                        
                                        if puff["NewCommentUsernames"] != nil {
                                            self.commentUsernames.append(puff["NewCommentUsernames"] as! [String])
                                        } else {
                                            self.commentUsernames.append([])
                                        }
                                        
                                        if puff["NewComments"] == nil {
                                            self.commentsNil.append(true)
                                            self.comments.append([])
                                        } else {
                                            self.commentsNil.append(false)
                                            self.comments.append(puff["NewComments"] as! [String])
                                        }
                                        
                                        
                                        if let actualId = puff.objectId {
                                            self.objectId.append(actualId)
                                        }
                                        
                                        if puff["IsCommentDeleted"] != nil {
                                            
                                            self.deletedComments.append(puff["IsCommentDeleted"] as! [Bool])
                                            
                                            var i = 0
                                            
                                            for deleted in self.deletedComments[mainIndex] {
                                                
                                                if !deleted {
                                                    
                                                    self.checkedComments[mainIndex].append(self.comments[mainIndex][i])
                                                    self.checkedUsernames[mainIndex].append(self.commentUsernames[mainIndex][i])
                                                    
                                                }
                                                
                                                i++
                                            }
                                            
                                        } else {
                                            
                                            self.deletedComments.append([])
                                            self.checkedComments[mainIndex] = []
                                            self.checkedUsernames[mainIndex] = []
                                        }
                                        
                                        mainIndex++
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    if !self.firstLoad {
                        if self.isImage[0] == false {
                            self.PlayPauseView.alpha = 1
                            self.firstLoad = true
                        }
                    }
                    
                    self.PuffTableView.reloadData()
                    self.urlToAsset()
                    self.loading = false
                    
                    
                }
            } else {
                
                print("\(error)")
                
            }
        }
    }
    
    func urlToAsset() {
        
        self.asset.removeAll()
        
        for var i = 0; i < videoUrls.count; i++ {
            
            if isImage[i] == true {
                self.asset.append(AVURLAsset(URL: NSURL(string: "")!))
            } else {
                
                if let url = NSURL(string: videoUrls[i]) {
                    self.asset.append(AVURLAsset(URL: url))
                    self.myTableView.reloadData()
                }
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
            
            cell.imageUrl = dormroomurl + imageUrls[indexPath.row]
            cell.profileUrl = dormroomurl + profilePictureURLS[indexPath.row]
            cell.timePostedVar = timeAgoSince(date)
            cell.username = usernames[indexPath.row]
            cell.captionVar = captions[indexPath.row]
            cell.likeVar = "\(likes[indexPath.row])"
            cell.dislikeVar = "\(dislikes[indexPath.row])"
            
            cell.indexPath = indexPath.row
            
            cell.objectId = objectId[indexPath.row]
            
            cell.like = likes[indexPath.row]
            
            cell.dislike = dislikes[indexPath.row]
            
            cell.timePosted.text = timeAgoSince(date)
            
            cell.ImageOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + imageUrls[indexPath.row])), placeholderImage: nil) { (image, error, cache, url) -> Void in
                
                if error == nil {
                    cell.SwipeViewOutlet.image = image
                }
            }
            
            if checkedComments[indexPath.row].count == 0 {
                
                cell.ViewHowManyComments.text = "Be First to Comment!"
                
                cell.MostRecentCommentOutlet.alpha = 0
                cell.MostRecentUsername.alpha = 0
                cell.SecondRecentUsername.alpha = 0
                cell.SecondRecentComment.alpha = 0
                
            }
            
            if checkedComments[indexPath.row].count == 1 {
                
                cell.MostRecentCommentOutlet.alpha = 1
                cell.MostRecentUsername.alpha = 1
                
                cell.MostRecentCommentOutlet.text = checkedComments[indexPath.row].first
                cell.MostRecentUsername.text = checkedUsernames[indexPath.row].first
                
                cell.SecondRecentComment.alpha = 0
                cell.SecondRecentUsername.alpha = 0
                
                cell.ViewHowManyComments.text = "Be Second to Comment!"
                
            } else if checkedComments[indexPath.row].count >= 2 {
                
                cell.MostRecentCommentOutlet.alpha = 1
                cell.MostRecentUsername.alpha = 1
                cell.SecondRecentUsername.alpha = 1
                cell.SecondRecentComment.alpha = 1
                
                print(checkedUsernames[indexPath.row][1])
                
                cell.MostRecentCommentOutlet.text = checkedComments[indexPath.row].first
                cell.MostRecentUsername.text = checkedUsernames[indexPath.row].first
                cell.SecondRecentComment.text = checkedComments[indexPath.row][1]
                cell.SecondRecentUsername.text = checkedUsernames[indexPath.row][1]
                
                if checkedComments[indexPath.row].count == 2 {
                    cell.ViewHowManyComments.text = "Be Third to Comment"
                } else {
                    cell.ViewHowManyComments.text = "View all \(checkedComments[indexPath.row].count) comments"
                }
            }
            
            cell.mainController = self
            
            cell.UsernameOutlet.text = usernames[indexPath.row]
            
            cell.ProfileOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + profilePictureURLS[indexPath.row])))
            
            if usernames[indexPath.row] == user?.username {
                
                cell.ReportOutlet.text = "Delete?"
                cell.repDel = "Delete?"
                
            } else {
                
                cell.ReportOutlet.text = "Report?"
                cell.repDel = "Report?"
            }
            
            
            cell.CaptionOutlet.text = captions[indexPath.row]
            
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
                cell.DislikeButtonOutlet.userInteractionEnabled = true
                
                
            } else {
                
                cell.LikeButtonOutlet.image = nil
                cell.LikeButtonOutlet.userInteractionEnabled = false
                
                cell.DislikeButtonOutlet.image = nil
                cell.DislikeButtonOutlet.userInteractionEnabled = false
                
            }
            
            
            switch universityNames[indexPath.row] {
                
            case "Brock":
                cell.UniversityNameOutlet.text = "Brock Univeristy"
                cell.uniName = "Brock Univeristy"
                
            case "Calgary":
                cell.UniversityNameOutlet.text = "University of Calgary"
                cell.uniName = "University of Calgary"
                
            case "Carlton":
                cell.UniversityNameOutlet.text = "Carleton University"
                cell.uniName = "Carleton University"
                
            case "Dalhousie":
                cell.UniversityNameOutlet.text = "Dalhousie University"
                cell.uniName = "Dalhousie University"
                
            case "Laurier":
                cell.UniversityNameOutlet.text = "Wilfred Laurier University"
                cell.uniName = "Wilfred Laurier University"
                
            case "McGill":
                cell.UniversityNameOutlet.text = "McGill University"
                cell.uniName = "McGill University"
                
            case "Mac":
                cell.UniversityNameOutlet.text = "McMaster University"
                cell.uniName = "McMaster University"
                
            case "Mun":
                cell.UniversityNameOutlet.text = "Memorial University"
                cell.uniName = "Memorial University"
                
            case "Ottawa":
                cell.UniversityNameOutlet.text = "University of Ottawa"
                cell.uniName = "University of Ottawa"
                
            case "Queens":
                cell.UniversityNameOutlet.text = "Queens University"
                cell.uniName = "Queens University"
                
            case "Ryerson":
                cell.UniversityNameOutlet.text = "Ryerson University"
                cell.uniName = "Ryerson University"
                
            case "UBC":
                cell.UniversityNameOutlet.text = "University of British Colombia"
                cell.uniName = "University of British Colombia"
                
            case "UofT":
                cell.UniversityNameOutlet.text = "University of Toronto"
                cell.uniName = "University of Toronto"
                
            case "Western":
                cell.UniversityNameOutlet.text = "University of Western Ontario"
                cell.uniName = "University of Western Ontario"
                
            case "York":
                cell.UniversityNameOutlet.text = "York University"
                cell.uniName = "York University"
                
            case "OtherUni":
                cell.UniversityNameOutlet.text = "Other"
                cell.uniName = "Other"
                
            default:
                break
                
            }
            
            cell.LikeOutlet.text = "\(likes[indexPath.row])"
            
            cell.DislikeOutlet.text = "\(dislikes[indexPath.row])"
            
            cell.feed = feed
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoTableViewCell
            
            cell.selectionStyle = .None
            
            cell.profileUrl = dormroomurl + profilePictureURLS[indexPath.row]
            cell.timePostedVar = timeAgoSince(date)
            cell.username = usernames[indexPath.row]
            cell.captionVar = captions[indexPath.row]
            cell.likeVar = "\(likes[indexPath.row])"
            cell.dislikeVar = "\(dislikes[indexPath.row])"
            cell.asset = asset[indexPath.row]
            
            if indexPath.row == index {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    if self.videoPlayerLayer != nil {
                        self.videoPlayerLayer.removeFromSuperlayer()
                    }
                    
                    self.videoPlayerItem = AVPlayerItem(asset: self.asset[indexPath.row])
                    self.videoPlayer = AVPlayer(playerItem: self.videoPlayerItem)
                    self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
                    
                    cell.VideoView.layer.addSublayer(self.videoPlayerLayer)
                    cell.VideoView.alpha = 1
                    self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.videoPlayerLayer.frame = cell.VideoView.bounds

                    self.PlayPauseView.alpha = 1
                    self.PlayPauseImage.image = UIImage(named: "pauseIcon")
                    self.videoPlayer.play()
                    
                    NSNotificationCenter.defaultCenter().addObserver(self,
                        selector: "playerItemDidReachEnd:",
                        name: AVPlayerItemDidPlayToEndTimeNotification,
                        object: self.videoPlayer.currentItem)
                    
                })
            }
            
            cell.selectionStyle = .None
            
            cell.indexPath = indexPath.row
            
            cell.objectId = objectId[indexPath.row]
            
            cell.like = likes[indexPath.row]
            
            cell.dislike = dislikes[indexPath.row]
            
            cell.timePosted.text = timeAgoSince(date)
            
            if checkedComments[indexPath.row].count == 0 {
                
                cell.HowManyComments.text = "Be First to Comment!"
                
                cell.MostRecentComment.alpha = 0
                cell.MostRecentUsername.alpha = 0
                cell.SecondComment.alpha = 0
                cell.SecondUsername.alpha = 0
                
            }
            
            if checkedComments[indexPath.row].count == 1 {
                
                cell.MostRecentComment.alpha = 1
                cell.MostRecentUsername.alpha = 1
                
                cell.MostRecentComment.text = checkedComments[indexPath.row].first
                cell.MostRecentUsername.text = checkedUsernames[indexPath.row].first
                
                cell.SecondUsername.alpha = 0
                cell.SecondComment.alpha = 0
                
                cell.HowManyComments.text = "Be Second to Comment!"
                
            } else if checkedComments[indexPath.row].count >= 2 {
                
                cell.MostRecentComment.alpha = 1
                cell.MostRecentUsername.alpha = 1
                cell.SecondComment.alpha = 1
                cell.SecondUsername.alpha = 1
                
                print(checkedUsernames[indexPath.row][1])
                
                cell.MostRecentComment.text = checkedComments[indexPath.row].first
                cell.MostRecentUsername.text = checkedUsernames[indexPath.row].first
                cell.SecondComment.text = checkedComments[indexPath.row][1]
                cell.SecondUsername.text = checkedUsernames[indexPath.row][1]
                
                if checkedComments[indexPath.row].count == 2 {
                    cell.HowManyComments.text = "Be Third to Comment"
                } else {
                    cell.HowManyComments.text = "View all \(checkedComments[indexPath.row].count) comments"
                }
            }
            
            cell.mainController = self
            
            cell.UsernameOutlet.text = usernames[indexPath.row]
            
            cell.ProfileOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + profilePictureURLS[indexPath.row])))
            
            if usernames[indexPath.row] == user?.username {
                
                cell.ReportOutlet.text = "Delete?"
                cell.repDel = "Delete?"
                
                
            } else {
                
                cell.ReportOutlet.text = "Report?"
                cell.repDel = "Report?"
                
            }
            
            
            cell.CaptionOutlet.text = captions[indexPath.row]
            
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
                cell.DislikeButtonOutlet.userInteractionEnabled = true
                
                
            } else {
                
                cell.LikeButtonOutlet.image = nil
                cell.LikeButtonOutlet.userInteractionEnabled = false
                
                cell.DislikeButtonOutlet.image = nil
                cell.DislikeButtonOutlet.userInteractionEnabled = false
                
            }
            
            
            switch universityNames[indexPath.row] {
                
            case "Brock":
                cell.UniversityName.text = "Brock Univeristy"
                cell.uniName = "Brock Univeristy"
                
            case "Calgary":
                cell.UniversityName.text = "University of Calgary"
                cell.uniName = "University of Calgary"
                
            case "Carlton":
                cell.UniversityName.text = "Carleton University"
                cell.uniName = "Carleton University"
                
            case "Dalhousie":
                cell.UniversityName.text = "Dalhousie University"
                cell.uniName = "Dalhousie University"
                
            case "Laurier":
                cell.UniversityName.text = "Wilfred Laurier University"
                cell.uniName = "Wilfred Laurier University"
                
            case "McGill":
                cell.UniversityName.text = "McGill University"
                cell.uniName = "McGill University"
                
            case "Mac":
                cell.UniversityName.text = "McMaster University"
                cell.uniName = "McMaster University"
                
            case "Mun":
                cell.UniversityName.text = "Memorial University"
                cell.uniName = "Memorial University"
                
            case "Ottawa":
                cell.UniversityName.text = "University of Ottawa"
                cell.uniName = "University of Ottawa"
                
            case "Queens":
                cell.UniversityName.text = "Queens University"
                cell.uniName = "Queens University"
                
            case "Ryerson":
                cell.UniversityName.text = "Ryerson University"
                cell.uniName = "Ryerson University"
                
            case "UBC":
                cell.UniversityName.text = "University of British Colombia"
                cell.uniName = "University of British Colombia"
                
            case "UofT":
                cell.UniversityName.text = "University of Toronto"
                cell.uniName = "University of Toronto"
                
            case "Western":
                cell.UniversityName.text = "University of Western Ontario"
                cell.uniName = "University of Western Ontario"
                
            case "York":
                cell.UniversityName.text = "York University"
                cell.uniName = "York University"
                
            case "OtherUni":
                cell.UniversityName.text = "Other"
                cell.uniName = "Other"
                
            default:
                break
                
            }
            
            cell.LikeOutlet.text = "\(likes[indexPath.row])"
            
            cell.DislikeOutlet.text = "\(dislikes[indexPath.row])"
            
            cell.feed = feed
            
            return cell
        }
        
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.videoPlayer.seekToTime(kCMTimeZero)
        self.videoPlayer.play()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  imageUrls.count
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !tapToTop {
            
            wasVisible = false
            
            PlayPauseImage.image = UIImage(named: "playIcon")
            didClickPlay = false
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.PlayPauseView.alpha = 0
            })
            
            if videoPlayer != nil {
                self.videoPlayer.pause()
            }
            
        }
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let actualCell = cell as? VideoTableViewCell else {return}
        actualCell.VideoView.alpha = 0
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        tapToTop = false
        
    }
    
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("End Dragging")
        
        let cells = myTableView.visibleCells
        
        print(cells.count)
        
        if tapToTop {
            
            if videoPlayer != nil {
                
                PlayPauseImage.image = UIImage(named: "pauseIcon")
                PlayPauseView.alpha = 1
                videoPlayer.play()
                myTableView.reloadData()
            }
            
        } else if PlayPauseView.alpha != 1 {
            
            for cell in cells {
                
                if let actualCell = cell as? VideoTableViewCell {
                    
                    let indexPath = myTableView.indexPathForCell(actualCell)
                    var cellRect: CGRect = CGRect()
                    
                    if let actualPath = indexPath {
                        
                        cellRect = myTableView.rectForRowAtIndexPath(actualPath)
                        
                        let smallerRect = CGRectInset(cellRect, 0, 100)
                        
                        let visible = CGRectContainsRect(myTableView.bounds, smallerRect)
                        
                        print(visible)
                        
                        if visible {
                            
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.PlayPauseView.alpha = 1
                            })
                            
                            if index != indexPath?.row {
                                
                                wasVisible = visible
                                index = actualPath.row
                                myTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        print("End Decelerating")
        
        let cells = myTableView.visibleCells
        
        print(cells.count)
        
        if tapToTop {
            
            if videoPlayer != nil {
                
                PlayPauseImage.image = UIImage(named: "pauseIcon")
                PlayPauseView.alpha = 1
                videoPlayer.play()
                myTableView.reloadData()
            }
            
        } else if PlayPauseView.alpha != 1 {
            
            for cell in cells {
                
                if let actualCell = cell as? VideoTableViewCell {
                    
                    let indexPath = myTableView.indexPathForCell(actualCell)
                    var cellRect: CGRect = CGRect()
                    
                    if let actualPath = indexPath {
                        
                        cellRect = myTableView.rectForRowAtIndexPath(actualPath)
                        
                        let smallerRect = CGRectInset(cellRect, 0, 100)
                        
                        let visible = CGRectContainsRect(myTableView.bounds, smallerRect)
                        
                        print(visible)
                        
                        if visible {
                            
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.PlayPauseView.alpha = 1
                            })
                            
                            
                            if index != indexPath?.row {
                                
                                wasVisible = visible
                                index = actualPath.row
                                myTableView.reloadData()
                            }
                        }
                    }
                }
            }
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
