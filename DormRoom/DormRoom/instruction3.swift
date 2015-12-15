//
//  instruction3.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-14.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class instruction3: UIViewController {
    
    @IBAction func doneAction(sender: AnyObject) {
        
        if let vc: UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("MainController")) {
            vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            presentViewController(vc, animated: true, completion: nil)
        
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
