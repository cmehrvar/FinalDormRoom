//
//  MainPuffViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class MainPuffViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var rootController: MainRootViewController?
    
    var user = PFUser.currentUser()
    
    var images = [PFFile]()
    var profilePictures = [PFFile]()
    var universityNames = [String]()
    var universityFiles = [PFFile]()
    var captions = [String]()
    var likes = [Int]()
    var dislikes = [Int]()
    var objectId = [String]()
    
    var feed = "CanadaPuff"
    var ranking = "createdAt"
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        
        if feed == "CanadaPuff" {
            TakeAPuffOutlet.alpha = 1
        } else if feed != user?["universityName"] as! String {
            TakeAPuffOutlet.alpha = 0
        } else {
            TakeAPuffOutlet.alpha = 1
        }
        
        loadFromParse()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        // Do any additional setup after loading the view.
    }
    
    //Outlets
    @IBOutlet weak var PuffTableView: UITableView!
    @IBOutlet weak var TakeAPuffOutlet: UIView!
    
    
    //Actions
    @IBAction func takePuffAction(sender: AnyObject) {
        
        
        
        
    }
    
    
    @IBAction func menuAction(sender: AnyObject) {
        
        rootController?.toggleMenu({ (Bool) -> () in
            print("menu opened")
        })
    }
    
    
    //Functions
    func loadFromParse() {
        
        images.removeAll()
        profilePictures.removeAll()
        likes.removeAll()
        dislikes.removeAll()
        captions.removeAll()
        universityFiles.removeAll()
        universityNames.removeAll()
        objectId.removeAll()
        
        
        let query = PFQuery(className: feed)
        query.orderByDescending(ranking)
        
        query.findObjectsInBackgroundWithBlock { (puffs: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let puffs = puffs {
                    
                    for puff in puffs {
                        
                        self.images.append(puff["Image"] as! PFFile)
                        self.profilePictures.append(puff["ProfilePicture"] as! PFFile)
                        self.captions.append(puff["Caption"] as! String)
                        self.likes.append(puff["Like"] as! Int)
                        self.dislikes.append(puff["Dislike"] as! Int)
                        self.universityNames.append(puff["UniversityName"] as! String)
                        self.universityFiles.append(puff["UniversityFile"] as! PFFile)
                        
                        if let actualId = puff.objectId {
                            self.objectId.append(actualId)
                        }
                        
                        self.PuffTableView.reloadData()
                    }
                }
            } else {
                
                print("\(error)")
                
            }
        }
    }
    
    func refresh(sender: AnyObject) {
        
        loadFromParse()
        refreshControl.endRefreshing()
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
        
        //FILL IN
        
        
    }
    
   
    
    //TableView shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.decelerationRate = 0.1
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PuffCell", forIndexPath: indexPath) as! PuffTableViewCell
        
        tableView.addSubview(refreshControl)
        
        cell.selectionStyle = .None
        
        cell.ImageOutlet.imageFromPFFile(images[indexPath.row], placeholder: "Crest")
        
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
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
