//
//  ImageViewExtension.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-30.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    public func imageFromPFFile(file: PFFile, placeholder: String?) {
        
        if let actualPlaceholder = placeholder {
            image = UIImage(named: actualPlaceholder)
        }
        
        var possibleImageData = NSData()
        
        do {
            possibleImageData = try file.getData()
        } catch let error {
            print("error grabbing image: \(error)")
        }
        
        guard let image = UIImage(data: possibleImageData) else {return}
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self.image = image
            
        }
    }
    
    public func imageFromPFFile(file: PFFile) {
        
        imageFromPFFile(file, placeholder: nil)
        
    }
}
