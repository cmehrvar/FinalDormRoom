//
//  CommentsViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-19.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    weak var rootController: MainRootViewController?
    
    var comments = [String]()
    var objectId = String()
    var feed = String()
    
    var refreshControl: UIRefreshControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCloseSwipe()
        addTapGesture()
        addRefresh()
        //configureTableView()
        // Do any additional setup after loading the view.
    }

    
    //Outlets
    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var University: UIImageView!
    @IBOutlet weak var ProfilePicture: UIImageView!
    @IBOutlet weak var Username: UILabel!
    @IBOutlet weak var CommentText: UITextView!
    @IBOutlet weak var CommentTableView: UITableView!
    @IBOutlet weak var commentIcon: UIImageView!
    
    
    //Actions
    @IBAction func post(sender: AnyObject) {
        
        let query = PFQuery(className: feed)
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error != nil {
                print(error)
            } else if let post = post {
                
                self.comments = post["Comments"] as! [String]
                
                post["Comments"] = [self.CommentText.text] + self.comments
                
                post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    if error == nil {
                        
                        self.CommentText.text = ""
                        
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.commentIcon.alpha = 1
                        })
                        
                        self.loadFromParse()
                        
                    } else {
                        print("error")
                    }
                    
                })
            }
        }
        
        view.endEditing(true)
    }
    
    @IBAction func hideButton(sender: AnyObject) {
        
        
        
        rootController?.toggleComments({ (Bool) -> () in
            
            guard let actualController = self.rootController else {return}
            
            actualController.mainController?.commentsOpened = false
            
            self.view.endEditing(true)
            self.CommentText.text = ""
            self.commentIcon.alpha = 0
            self.comments.removeAll()
            self.CommentTableView.reloadData()
            
        })
        
        
        
    }
    
    //Functions
    func addRefresh() {
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Keep on Puffin'")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    func refresh(sender: AnyObject) {
        
        loadFromParse()
        refreshControl.endRefreshing()
    }


    
    
    func configureTableView() {
        CommentTableView.rowHeight = UITableViewAutomaticDimension
        CommentTableView.estimatedRowHeight = 44.0
    }
    
    func loadFromParse() {
        
        let query = PFQuery(className: feed)
        
        query.getObjectInBackgroundWithId(objectId) { (post: PFObject?, error: NSError?) -> Void in
            
            if error == nil && post != nil {
                
                self.comments.removeAll()
                
                do {
                    try post?.fetch()
                } catch let error {
                    print(error)
                }
                
                if post?["Comments"] != nil {
                
                self.comments = post?["Comments"] as! [String]
                
                self.CommentTableView.reloadData()
                
                } else {
                    
                    
                    let query = PFQuery(className: self.feed)
                    query.getObjectInBackgroundWithId(self.objectId) { (post: PFObject?, error: NSError?) -> Void in
                        
                        if error != nil {
                            print(error)
                        } else if let post = post {
                            
                            post["Comments"] = []
                            
                            post.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                                
                                if error == nil {
                                    
                                    print("success")
                                    
                                } else {
                                    print("error")
                                }
                                
                            })
                        }
                    }

                }
            } else {
                print(error)
            }
         }
    }
    
    
    
    func addCloseSwipe() {
        
        let closeSwipe: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "closeMenu:")
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(closeSwipe)
        
    }
    
    func closeMenu(sender: UIPanGestureRecognizer) {
        
        var initialShit: CGFloat = CGFloat()
        let translation = sender.translationInView(view)
        
        
        switch sender.state {
            
        case .Began:
            initialShit = translation.x
    
            
        case .Ended:
            
            if translation.x < initialShit {
                
                rootController?.toggleComments({ (Bool) -> () in
                    self.view.endEditing(true)
                    
                    guard let actualController = self.rootController else {return}
                    actualController.mainController?.commentsOpened = false
                    
                    self.CommentText.text = ""
                    self.commentIcon.alpha = 1
                    self.comments.removeAll()
                    self.CommentTableView.reloadData()
                })
                
            }
            
        default:
            break
        }
    }
    
    
    func addTapGesture() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    //TableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.addSubview(refreshControl)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CommentsCell", forIndexPath: indexPath) as! CommentsCell
        
        cell.selectionStyle = .None
        
        cell.textLabel?.text = comments[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            
            self.commentIcon.alpha = 0
            
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
        if CommentText.text == "" {
            
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.commentIcon.alpha = 1
                
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
