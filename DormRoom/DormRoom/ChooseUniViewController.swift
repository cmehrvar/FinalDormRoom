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
    
    var staticImages = [UIImage]()
    var universityNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFeedImages()
        // Do any additional setup after loading the view.
    }
    
    //Outlets
    @IBOutlet weak var ChooseUniTableViewOutlet: UITableView!
    
    
    //Functions
    func addFeedImages() {
        
        guard let dal = UIImage(named: "Dalhousie"), mcgill = UIImage(named: "McGill"), queens = UIImage(named: "Queens"), ryerson = UIImage(named: "Ryerson"), western = UIImage(named: "Western"), calgary = UIImage(named: "Calgary"), ubc = UIImage(named: "UBC") else {return}
        
        staticImages.append(dal)
        universityNames.append("Dalhousie")
        staticImages.append(mcgill)
        universityNames.append("McGill")
        staticImages.append(queens)
        universityNames.append("Queens")
        staticImages.append(ryerson)
        universityNames.append("Ryerson")
        staticImages.append(western)
        universityNames.append("Western")
        staticImages.append(calgary)
        universityNames.append("Calgary")
        staticImages.append(ubc)
        universityNames.append("UBC")
        
        ChooseUniTableViewOutlet.reloadData()
    }

    
    //TableView shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChooseUniCell", forIndexPath: indexPath) as! ChooseUniCellTableViewCell
        
        tableView.decelerationRate = 0.1
        
        cell.selectionStyle = .None
        
        cell.UniversityImageOutlet.image = staticImages[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staticImages.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let actualController = rootController else {return}
        
        actualController.signUpViewController?.universityName = universityNames[indexPath.row]
        actualController.signUpViewController?.UniOutlet.image = staticImages[indexPath.row]
        
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
