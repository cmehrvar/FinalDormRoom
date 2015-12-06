//
//  ChangeUniViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class ChangeUniViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: MainRootViewController?
    let user = PFUser.currentUser()
    
    var universityFiles = [PFFile]()
    var universityNames = [String]()
    
    @IBOutlet weak var ChooseUniTableViewOutlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUnisFromParse()
        // Do any additional setup after loading the view.
    }
    
    //TableView shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChangeUniCell", forIndexPath: indexPath) as! ChangeUniCell
        
        tableView.decelerationRate = 0.1
        
        cell.selectionStyle = .None
        
        cell.ChangeUniImageOutlet.imageFromPFFile(universityFiles[indexPath.row], placeholder: "Crest")
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return universityFiles.count
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        user?["universityName"] = universityNames[indexPath.row]
        user?["universityFile"] = universityFiles[indexPath.row]
        user?.saveEventually()
        
        guard let actualController = rootController else {return}
        
        actualController.menuController?.UniversityOutlet.imageFromPFFile(universityFiles[indexPath.row], placeholder: "Crest")
        rootController?.toggleChangeUni({ (complete) -> () in
            print("change uni closed")
        })
    }
    
    
    
    //Functions
    func loadUnisFromParse() {
        
        universityFiles.removeAll()
        universityNames.removeAll()
        
        self.ChooseUniTableViewOutlet.reloadData()
        
        let query = PFQuery(className: "Universities")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (unis: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                
                if let unis = unis {
                    
                    for uni in unis {
                        self.universityFiles.append(uni["Image"] as! PFFile)
                        self.universityNames.append(uni["Name"] as! String)
                        self.ChooseUniTableViewOutlet.reloadData()
                    }
                }
            } else {
                print(error)
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
