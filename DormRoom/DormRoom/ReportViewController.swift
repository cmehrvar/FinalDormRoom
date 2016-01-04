//
//  ReportViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ReportViewController: UIViewController {
    
    weak var rootController: MainRootViewController?
    
    //Outlets
    @IBOutlet weak var ProfilePicture: RoundedImage!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func noAction(sender: AnyObject) {
    }
    
    
    @IBAction func yesAction(sender: AnyObject) {
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
