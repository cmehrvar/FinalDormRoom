//
//  MenuViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var rootController: MainRootViewController?
    var user = PFUser.currentUser()
 
    var feedFiles = [PFFile]()
    var staticImages = [UIImage]()
    
    
    var feedName: [String] = ["CanadaPuff", "CanadaPuff", "CanadaPuff"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRecognizers()
        
        addFeedImages()
        loadFromParse()
        
        retrieveProfilePicture()
        retrieveUniversity()
        
        FeedTableViewOutlet.reloadData()
        // Do any additional setup after loading the view.
    }
    
    
    //Outlets
    @IBOutlet weak var ProfileOutlet: UIImageView!
    @IBOutlet weak var UniversityOutlet: UIImageView!
    @IBOutlet weak var FeedTableViewOutlet: UITableView!
    
    
    //Actions
    @IBAction func logOut(sender: AnyObject) {
        
        PFUser.logOut()
        user = PFUser.currentUser()
        
        if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("LogInController")) {
            
            vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func hide(sender: AnyObject) {
        
        rootController?.toggleMenu({ (complete) -> () in
            print("toggled closed")
        })
    }
    
    
    //TableView Shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseFeedCell", forIndexPath: indexPath) as! ChooseFeedCell
        
        cell.selectionStyle = .None
        
        if indexPath.row <= (staticImages.count - 1) {
            cell.FeedImageOutlet.image = staticImages[indexPath.row]
        } else {
            
            let realIndexPath = indexPath.row - (staticImages.count)
            cell.FeedImageOutlet.imageFromPFFile(feedFiles[realIndexPath])
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let actualController = rootController else {return}
        
        if indexPath.row >= 1 {
            
            if feedName[indexPath.row - 1] == "CanadaPuff" {
                
                actualController.mainController?.TakeAPuffOutlet.alpha = 1
                
            } else if user?["universityName"] as! String != feedName[indexPath.row - 1] {
                
                actualController.mainController?.TakeAPuffOutlet.alpha = 0
                
            } else {
                
                actualController.mainController?.TakeAPuffOutlet.alpha = 1
                
            }
        }
        
        if indexPath.row == 0 {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                actualController.mainController?.WebViewOutlet.alpha = 1
            })
            
        } else if indexPath.row == 1 {
            
            let feed = feedName[indexPath.row - 1]
            
            actualController.mainController?.ranking = "createdAt"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse()
            
            actualController.mainController?.WebViewOutlet.alpha = 0
            
        } else if indexPath.row == 2 {
            
            let feed = feedName[indexPath.row - 1]
            
            actualController.mainController?.ranking = "Like"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse()
            
            actualController.mainController?.WebViewOutlet.alpha = 0
            
        } else if indexPath.row == 3 {
            
            let feed = feedName[indexPath.row - 1]
            
            actualController.mainController?.ranking = "Dislike"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse()
            
            actualController.mainController?.WebViewOutlet.alpha = 0
            
        } else {
            
            let feed = feedName[indexPath.row - 1]
            
            actualController.mainController?.feed = "createdAt"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse()
            
            actualController.mainController?.WebViewOutlet.alpha = 0
        }
        
        
        rootController?.toggleMenu({ (complete) -> () in
            
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (staticImages.count + feedFiles.count)
    }
    
    
    //Functions
    func addFeedImages() {
        
        guard let crest = UIImage(named: "Crest"), canada = UIImage(named: "Canada"), topRated = UIImage(named: "TopRated"), topHated = UIImage(named: "TopHated") else {return}
        
        staticImages.append(crest)
        staticImages.append(canada)
        staticImages.append(topRated)
        staticImages.append(topHated)
    }
    
    
    func retrieveProfilePicture() {
        
        let imageFile: PFFile = user?["profilePicture"] as! PFFile
        self.ProfileOutlet.imageFromPFFile(imageFile)
        
    }
    
    
    func retrieveUniversity() {
        
        let imageFile: PFFile = user?["universityFile"] as! PFFile
        self.UniversityOutlet.imageFromPFFile(imageFile)
        
    }
    
    func saveProfile(profile: UIImage) {
        
        guard let data = UIImageJPEGRepresentation(profile, 0.5), pfProfile = PFFile(data: data) else {return}
        
        user?["profilePicture"] = pfProfile as PFFile
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                //if saved
                print("saved profile picture to parse!")
            } else {
                
                let alertController = UIAlertController(title: "Sorry", message: "We couldn't change your profile picture", preferredStyle:  UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func addRecognizers() {
        
        let profilePictureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped")
        let universityRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "universityTapped")
        let closeMenu: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "closeMenu:")
        
        self.view.userInteractionEnabled = true
        self.ProfileOutlet.userInteractionEnabled = true
        self.UniversityOutlet.userInteractionEnabled = true
      
        self.view.addGestureRecognizer(closeMenu)
        self.ProfileOutlet.addGestureRecognizer(profilePictureRecognizer)
        self.UniversityOutlet.addGestureRecognizer(universityRecognizer)
        
    }
    
    func closeMenu(sender: UISwipeGestureRecognizer) {
        
        if sender.direction == .Right {
            
            rootController?.toggleMenu({ (complete) -> () in
                print("menu closed")
            })
        }
    }
    
    func profileTapped() {
        
        let cameraProfile = UIImagePickerController()
        
        cameraProfile.delegate = self
        cameraProfile.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            cameraProfile.sourceType = UIImagePickerControllerSourceType.Camera
        } else {
            cameraProfile.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        self.presentViewController(cameraProfile, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let temp: UIImage = image
        
        ProfileOutlet.image = temp
        saveProfile(temp)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func universityTapped() {
        
        rootController?.toggleChangeUni({ (complete) -> () in
            
        })
    }
    
    
    func loadFromParse() {
        
        let query = PFQuery(className: "Universities")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (unis:[PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let unis = unis {
                    
                    for uni in unis {
                        
                        self.feedFiles.append(uni["Image"] as! PFFile)
                        self.feedName.append(uni["Name"] as! String)
                        self.FeedTableViewOutlet.reloadData()
                    }
                }
                
            } else {
                print("error")
            }
            
            for feed in self.feedName {
                print(feed)
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
