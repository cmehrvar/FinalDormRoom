//
//  RoundedImage.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-30.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
        self.clipsToBounds = true
    }

}
