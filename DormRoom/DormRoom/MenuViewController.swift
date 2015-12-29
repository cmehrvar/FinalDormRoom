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

    var staticImages = [UIImage]()
    
    var websiteLoading = false
    
    var universityNames: [String] = ["CanadaPuff", "CanadaPuff", "CanadaPuff"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRecognizers()
        addFeedImages()
        retrieveProfilePicture()
        retrieveUniversity()
        
        //FeedTableViewOutlet.reloadData()
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
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            guard let actualController = self.rootController else {return}
            actualController.mainController?.ImageBlur.alpha = 0
        })
        
        rootController?.toggleMenu({ (complete) -> () in
            print("toggled closed")
            
            guard let actualController = self.rootController else {return}
            actualController.mainController?.myTableView.scrollEnabled = true
        })
    }
    
    
    //TableView Shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseFeedCell", forIndexPath: indexPath) as! ChooseFeedCell
        
        tableView.decelerationRate = 0.01
        
        cell.selectionStyle = .None
        
        cell.FeedImageOutlet.image = staticImages[indexPath.row]
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let actualController = rootController else {return}
        
        if indexPath.row >= 1 {
            
            if universityNames[indexPath.row - 1] == "CanadaPuff" {
                
                actualController.mainController?.TakeAPuffOutlet.alpha = 1
                
            } else if user?["universityName"] as! String != universityNames[indexPath.row - 1] {
                
                actualController.mainController?.TakeAPuffOutlet.alpha = 0
                
            } else {
                
                actualController.mainController?.TakeAPuffOutlet.alpha = 1
                
            }
        }
        
        if indexPath.row == 0 {
            
            if !websiteLoading {
                
                actualController.mainController?.loadWebsite()
                websiteLoading = true
                
            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                actualController.mainController?.WebViewOutlet.alpha = 1
                actualController.mainController?.funcToCallWhenStartLoadingYourWebview()
            })
            
        } else if indexPath.row == 1 {
            
            let feed = universityNames[indexPath.row - 1]
            
            actualController.mainController?.ranking = "createdAt"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse({ () -> Void in
                
            })
            
            actualController.mainController?.WebViewOutlet.alpha = 0
            
        } else if indexPath.row == 2 {
            
            let feed = universityNames[indexPath.row - 1]
            
            actualController.mainController?.ranking = "Like"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse({ () -> Void in
                
            })
            
            actualController.mainController?.WebViewOutlet.alpha = 0
            
        } else if indexPath.row == 3 {
            
            let feed = universityNames[indexPath.row - 1]
            
            actualController.mainController?.ranking = "Dislike"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse({ () -> Void in
                
            })
            
            actualController.mainController?.WebViewOutlet.alpha = 0
            
        } else {
            
            let feed = universityNames[indexPath.row - 1]
            
            actualController.mainController?.ranking = "createdAt"
            actualController.mainController?.feed = feed
            actualController.mainController?.loadFromParse({ () -> Void in
                
            })
            
            actualController.mainController?.WebViewOutlet.alpha = 0
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            guard let actualController = self.rootController else {return}
            actualController.mainController?.ImageBlur.alpha = 0
        })
        
        rootController?.toggleMenu({ (complete) -> () in
            guard let actualController = self.rootController else {return}
            actualController.mainController?.myTableView.scrollEnabled = true
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (staticImages.count)
    }
    
    
    //Functions
    func addFeedImages() {
        
        guard let crest = UIImage(named: "Crest"), canada = UIImage(named: "Canada"), topRated = UIImage(named: "TopRated"), topHated = UIImage(named: "MostHated"), brock = UIImage(named: "Brock"), calgary = UIImage(named: "Calgary"), carlton = UIImage(named: "Carleton"), dal = UIImage(named: "Dalhousie"), laurier = UIImage(named: "Laurier"), mcgill = UIImage(named: "McGill"), mac = UIImage(named: "Mac"), mun = UIImage(named: "Mun"), ottawa = UIImage(named: "Ottawa"), queens = UIImage(named: "Queens"), ryerson = UIImage(named: "Ryerson"), ubc = UIImage(named: "UBC"), uoft = UIImage(named: "UofT"), western = UIImage(named: "Western"), york = UIImage(named: "York") else {return}
        
        staticImages.append(crest)
        staticImages.append(canada)
        staticImages.append(topRated)
        staticImages.append(topHated)
        staticImages.append(brock)
        universityNames.append("Brock")
        staticImages.append(calgary)
        universityNames.append("Calgary")
        staticImages.append(carlton)
        universityNames.append("Carlton")
        staticImages.append(dal)
        universityNames.append("Dalhousie")
        staticImages.append(laurier)
        universityNames.append("Laurier")
        staticImages.append(mcgill)
        universityNames.append("McGill")
        staticImages.append(mac)
        universityNames.append("Mac")
        staticImages.append(mun)
        universityNames.append("Mun")
        staticImages.append(ottawa)
        universityNames.append("Ottawa")
        staticImages.append(queens)
        universityNames.append("Queens")
        staticImages.append(ryerson)
        universityNames.append("Ryerson")
        staticImages.append(ubc)
        universityNames.append("UBC")
        staticImages.append(uoft)
        universityNames.append("UofT")
        staticImages.append(western)
        universityNames.append("Western")
        staticImages.append(york)
        universityNames.append("York")

    }
    
    
    func retrieveProfilePicture() {
        
        let imageFile: PFFile = user?["profilePicture"] as! PFFile
        self.ProfileOutlet.imageFromPFFile(imageFile, placeholder: "Crest")
        
    }
    
    
    func retrieveUniversity() {
        
        let imageName: String = user?["universityName"] as! String
        
        switch imageName {
            
        case "Brock":
            self.UniversityOutlet.image = staticImages[4]
            
        case "Calgary":
            self.UniversityOutlet.image = staticImages[5]
            
        case "Carlton":
            self.UniversityOutlet.image = staticImages[6]
            
        case "Dalhousie":
            self.UniversityOutlet.image = staticImages[7]
            
        case "Laurier":
            self.UniversityOutlet.image = staticImages[8]
            
        case "McGill":
            self.UniversityOutlet.image = staticImages[9]
            
        case "Mac":
            self.UniversityOutlet.image = staticImages[10]
            
        case "Mun":
            self.UniversityOutlet.image = staticImages[11]
            
        case "Ottawa":
            self.UniversityOutlet.image = staticImages[12]
            
        case "Queens":
            self.UniversityOutlet.image = staticImages[13]
            
        case "Ryerson":
            self.UniversityOutlet.image = staticImages[14]
            
        case "UBC":
            self.UniversityOutlet.image = staticImages[15]
            
        case "UofT":
            self.UniversityOutlet.image = staticImages[16]
            
        case "Western":
            self.UniversityOutlet.image = staticImages[17]
            
        case "York":
            self.UniversityOutlet.image = staticImages[18]
            
        default:
            break
            
        }
    }
    
    func saveProfile(profile: UIImage) {
        
        guard let data = UIImageJPEGRepresentation(profile, 0.25), pfProfile = PFFile(data: data) else {return}
        
        user?["profilePicture"] = pfProfile as PFFile
        
        user?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            
            if (success) {
                //if saved
                print("saved profile picture to parse!")
            } else {
                
                let alertController = UIAlertController(title: "Shit...", message: "We couldn't change your profile picture", preferredStyle:  UIAlertControllerStyle.Alert)
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
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                guard let actualController = self.rootController else {return}
                actualController.mainController?.ImageBlur.alpha = 0
            })
            
            rootController?.toggleMenu({ (complete) -> () in
                
                guard let actualController = self.rootController else {return}
                actualController.mainController?.myTableView.scrollEnabled = true
                
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
