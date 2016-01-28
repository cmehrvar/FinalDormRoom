//
//  ProfilePictureView.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-27.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ProfilePictureView: UIView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayColor().CGColor
        layer.cornerRadius = 17
        self.clipsToBounds = true
        
    }
}
