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
    

    var universityNames = [String]()
    var staticImages = [UIImage]()
    
    @IBOutlet weak var ChooseUniTableViewOutlet: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFeedImages()
        // Do any additional setup after loading the view.
    }
    
    //TableView shit
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChangeUniCell", forIndexPath: indexPath) as! ChangeUniCell
        
        tableView.decelerationRate = 0.01
        
        cell.selectionStyle = .None
        
        cell.ChangeUniImageOutlet.image = staticImages[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return staticImages.count
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        user?["universityName"] = universityNames[indexPath.row]
        user?.saveEventually()
        
        guard let actualController = rootController else {return}
        
        actualController.menuController?.UniversityOutlet.image = staticImages[indexPath.row]
        rootController?.toggleChangeUni({ (complete) -> () in
            print("change uni closed")
        })
    }
    
    
    
    //Functions
    func addFeedImages() {
        
        guard let brock = UIImage(named: "Brock"), calgary = UIImage(named: "Calgary"), carlton = UIImage(named: "Carleton"), dal = UIImage(named: "Dalhousie"), laurier = UIImage(named: "Laurier"), mcgill = UIImage(named: "McGill"), mac = UIImage(named: "Mac"), mun = UIImage(named: "Mun"), ottawa = UIImage(named: "Ottawa"), queens = UIImage(named: "Queens"), ryerson = UIImage(named: "Ryerson"), ubc = UIImage(named: "UBC"), uoft = UIImage(named: "UofT"), western = UIImage(named: "Western"), york = UIImage(named: "York"), other = UIImage(named: "OtherUni") else {return}
        
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
        staticImages.append(other)
        universityNames.append("OtherUni")
        
        ChooseUniTableViewOutlet.reloadData()
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
