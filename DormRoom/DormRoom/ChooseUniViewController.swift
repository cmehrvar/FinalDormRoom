//
//  ChooseUniViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class ChooseUniViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var rootController: SignUpRootController?
    
    var universityFiles = [PFFile]()
    var universityNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUnisFromParse()
        //self.navigationItem.titleView = UIImageView(image: UIImage(named: "Logo"))
        // Do any additional setup after loading the view.
    }
    
    //Outlets
    @IBOutlet weak var ChooseUniTableViewOutlet: UITableView!
    
    
    //Functions
    func loadUnisFromParse() {
        
        universityFiles.removeAll()
        universityNames.removeAll()
        
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
    
    //TableView shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseUniCell", forIndexPath: indexPath) as! ChooseUniCellTableViewCell
        
        cell.selectionStyle = .None
        
        cell.UniversityImageOutlet.imageFromPFFile(universityFiles[indexPath.row])
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universityFiles.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let actualController = rootController else {return}
        
        actualController.signUpViewController?.universityFile = universityFiles[indexPath.row]
        actualController.signUpViewController?.universityName = universityNames[indexPath.row]
        actualController.signUpViewController?.UniOutlet.imageFromPFFile(universityFiles[indexPath.row])
        
        rootController?.toggleChooseUni({ (complete) -> () in
            
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
