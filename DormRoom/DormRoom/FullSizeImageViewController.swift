//
//  FullSizeImageViewController.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-02-02.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit
import AVFoundation

class FullSizeImageViewController: UIViewController {
    
    
    @IBOutlet weak var ImageOutlet: UIImageView!
    @IBOutlet weak var UsernameOutlet: UILabel!
    @IBOutlet weak var TimePostedOutlet: UILabel!
    @IBOutlet weak var ProfilePictureOutlet: UIImageView!
    @IBOutlet weak var UniversityNameOutlet: UILabel!
    @IBOutlet weak var ReportOutlet: UILabel!
    @IBOutlet weak var DislikeOutlet: UILabel!
    @IBOutlet weak var LikeOutlet: UILabel!
    @IBOutlet weak var CaptionOutlet: UILabel!
    @IBOutlet weak var VideoViewOutlet: UIView!
    @IBOutlet weak var PlayPauseView: UIView!
    @IBOutlet weak var PlayPauseImage: UIImageView!
    @IBOutlet weak var CaptionViewOutlet: UIView!
    @IBOutlet weak var InfoViewOutlet: UIView!
    
    
    
    let user = PFUser.currentUser()
    
    var videoPlayer: AVPlayer!
    var videoPlayerLayer: AVPlayerLayer!
    var videoPlayerItem: AVPlayerItem!
    
    var didClickPlay = false
    
    var isComment = Bool()
    var objectId = String()
    
    weak var rootController: MainRootViewController?
    
    
    @IBAction func reportDelete(sender: AnyObject) {
        
        guard let actualUsername = UsernameOutlet.text else {return}
        
        if actualUsername != user?.username {
            
            let alertController = UIAlertController(title: "So...", message: "You wanna report \(actualUsername)?", preferredStyle:  UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                
                var blockedPuffs = [String]()
                
                do {
                    try self.user?.fetch()
                } catch let error {
                    print(error)
                }
                
                blockedPuffs = self.user?["blockedPuffs"] as! [String]
                
                self.user?["blockedPuffs"] = [actualUsername] + blockedPuffs
                
                self.user?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        do {
                            try self.user?.fetch()
                            
                            self.rootController?.mainController?.loadFromParse({ (Bool) -> () in
                                
                            })
                            
                            self.rootController?.toggleFullSizeImage({ (Bool) -> () in
                                
                                if self.videoPlayerLayer != nil {
                                    self.videoPlayerLayer.removeFromSuperlayer()
                                }
                                
                                self.PlayPauseView.alpha = 0
                                self.CaptionViewOutlet.alpha = 0
                                self.InfoViewOutlet.alpha = 0
                                self.ImageOutlet.image = nil
                                
                            })
                            
                        } catch let error {
                            print(error)
                        }
                        
                    })
                    
                })
                
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        } else {
            
            let alertController = UIAlertController(title: "So...", message: "You wanna delete this?", preferredStyle:  UIAlertControllerStyle.Alert)
            
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { (UIAlertAction) -> Void in
                
                let query = PFQuery(className: "CanadaPuff")
                query.getObjectInBackgroundWithId(self.objectId, block: { (post: PFObject?, error: NSError?) -> Void in
                    
                    post?["Deleted"] = true
                    post?.saveInBackgroundWithBlock({ (Bool, error: NSError?) -> Void in
                        
                        self.rootController?.mainController?.loadFromParse({ (Bool) -> () in
                            
                            
                        })
                        
                        self.rootController?.toggleFullSizeImage({ (Bool) -> () in
                            
                            if self.videoPlayerLayer != nil {
                                self.videoPlayerLayer.removeFromSuperlayer()
                            }
                            
                            self.PlayPauseView.alpha = 0
                            self.CaptionViewOutlet.alpha = 0
                            self.InfoViewOutlet.alpha = 0
                            self.ImageOutlet.image = nil
                            
                        })

                    })
                })
            }))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    

    func playVideo(asset: AVURLAsset) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.videoPlayerItem = AVPlayerItem(asset: asset)
            self.videoPlayer = AVPlayer(playerItem: self.videoPlayerItem)
            self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
            
            self.VideoViewOutlet.layer.addSublayer(self.videoPlayerLayer)
            self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.videoPlayerLayer.frame = self.VideoViewOutlet.bounds
            
            self.videoPlayer.play()
            self.didClickPlay = true
            
            self.PlayPauseImage.image = UIImage(named: "pauseIcon")
            
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "playerItemDidReachEnd:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: self.videoPlayer.currentItem)
            
        })
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.videoPlayer.seekToTime(kCMTimeZero)
        self.videoPlayer.play()
    }
    
    
    
    @IBAction func pause(sender: AnyObject) {
        
        if videoPlayer != nil {
            
            if didClickPlay {
            
            self.videoPlayer.pause()
            self.PlayPauseImage.image = UIImage(named: "playIcon")
                
            } else {
                
                self.videoPlayer.play()
                self.PlayPauseImage.image = UIImage(named: "pauseIcon")
                
            }
            
            didClickPlay = !didClickPlay
            
        }
    }
    
    
    @IBAction func back(sender: AnyObject) {
        
        PlayPauseView.alpha = 0
        CaptionViewOutlet.alpha = 0
        InfoViewOutlet.alpha = 0
        
        rootController?.toggleFullSizeImage({ (Bool) -> () in
            self.ImageOutlet.image = nil
            
            if self.videoPlayerLayer != nil {
                self.videoPlayerLayer.removeFromSuperlayer()
            }
        })
        
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
