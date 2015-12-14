//
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
    
    let imageCache = SDImageCache()
    
    var user = PFUser.currentUser()
    
    var scroll = false
    var loading = false
    
    var didLoadWebsite = false

    var imageUrls = [String]()
    var image = UIImage()
    var profilePictureURLS = [String]()
    var profilePicture = UIImage()
    var universityNames = [String]()
    var captions = [String]()
    var likes = [Int]()
    var dislikes = [Int]()
    var objectId = [String]()
    
    var feed = String()
    var ranking = String()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        initializeFeeds()
        addScrollToTop()
        addRefresh()
        loadFromParse()
        addDownloadStuff()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    //Outlets
    @IBOutlet weak var PuffTableView: UITableView!
    @IBOutlet weak var TakeAPuffOutlet: UIView!
    @IBOutlet weak var WebViewOutlet: UIWebView!
    
    
    //Actions
    @IBAction func takePuffAction(sender: AnyObject) {
        
        guard let actualController = rootController else {return}
        
        actualController.takePuffController?.feed = feed
        
        rootController?.toggleTakePuff({ (complete) -> () in
            
        })
    }
    
    
    @IBAction func menuAction(sender: AnyObject) {
        
        rootController?.toggleMenu({ (Bool) -> () in
            print("menu opened")
        })
    }
    
    
    //Functions
    func addDownloadStuff(){
        
        let error = NSErrorPointer()
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("download"), withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error.memory = error1
            print("Creating 'download' directory failed. Error: \(error)")
        }
    }
    
    func addScrollToTop() {
        let tapScrollToTop: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "scrollToTop")
        self.navigationItem.titleView?.userInteractionEnabled = true
        self.navigationItem.titleView?.addGestureRecognizer(tapScrollToTop)
        
    }
    
    func scrollToTop() {
        myTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
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
        
        loadFromParse()
        refreshControl.endRefreshing()
    }
    
    
    func loadFromParse() {
        
        let query = PFQuery(className: feed)
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
                    self.objectId.removeAll()
                    
                    if let puffs = puffs {
                        
                        for puff in puffs {
                            
                            self.imageUrls.append(puff["ImageUrl"] as! String)
                            self.profilePictureURLS.append(puff["ProfilePictureUrl"] as! String)
                            self.captions.append(puff["Caption"] as! String)
                            self.likes.append(puff["Like"] as! Int)
                            self.dislikes.append(puff["Dislike"] as! Int)
                            self.universityNames.append(puff["UniversityName"] as! String)
                            
                            if let actualId = puff.objectId {
                                self.objectId.append(actualId)
                            }
                        }
                    }
                    
                    self.PuffTableView.reloadData()
                    
                    self.loading = false
                }
            } else {
                
                print("\(error)")
                
            }
        }
        
        if !didLoadWebsite {
            
            didLoadWebsite = true
            
            guard let url = NSURL(string: "http://www.dormroomnetwork.com/trending.html") else {return}
            
            WebViewOutlet.loadRequest(NSURLRequest(URL: url))
            
        }
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
        
        let dal = UIImage(named: "Dalhousie"), mcgill = UIImage(named: "McGill"), queens = UIImage(named: "Queens"), ryerson = UIImage(named: "Ryerson"), western = UIImage(named: "Western"), calgary = UIImage(named: "Calgary"), ubc = UIImage(named: "UBC")
        
        myTableView = tableView
        
        let dormroomurl = "https://s3.amazonaws.com/dormroombucket/"
        let placeholderImage = UIImage(named: "Crest")
        
        tableView.decelerationRate = 0.01
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PuffCell", forIndexPath: indexPath) as! PuffTableViewCell
        
        tableView.addSubview(refreshControl)
        
        cell.selectionStyle = .None
        
        cell.objectId = objectId[indexPath.row]
        
        cell.like = likes[indexPath.row]
        
        cell.dislike = dislikes[indexPath.row]
        
        cell.ImageOutlet.setImageWithURL(NSURL(string: (dormroomurl + imageUrls[indexPath.row])), placeholderImage: placeholderImage, completed: { (image, error, cache, url) -> Void in
            
            if error == nil {
                cell.SwipeViewOutlet.image = image
            }
            
            }, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        
        cell.ProfileOutlet.sd_setImageWithURL(NSURL(string: (dormroomurl + profilePictureURLS[indexPath.row])))
        
        switch universityNames[indexPath.row] {
            
        case "Dalhousie":
            cell.UniversityOutlet.image = dal
            
        case "McGill":
            cell.UniversityOutlet.image = mcgill
            
        case "Queens":
            cell.UniversityOutlet.image = queens
            
        case "Ryerson":
            cell.UniversityOutlet.image = ryerson
            
        case "Western":
            cell.UniversityOutlet.image = western
            
        case "Calgary":
            cell.UniversityOutlet.image = calgary
            
        case "UBC":
            cell.UniversityOutlet.image = ubc
            
        default:
            break
            
        }

        cell.LikeOutlet.text = "\(likes[indexPath.row])"
        
        cell.DislikeOutlet.text = "\(dislikes[indexPath.row])"
        
        cell.CaptionOutlet.text = captions[indexPath.row]
        
        cell.feed = feed
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if request.URL?.absoluteString == "http://www.dormroomnetwork.com/trending.html" {
            return true
        } else {
            return false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
        //loadFromParse()
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
