//
//  Username.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-21.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class Username: UIView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
    }
}
