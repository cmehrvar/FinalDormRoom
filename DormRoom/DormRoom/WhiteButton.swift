//
//  WhiteButton.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-30.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class WhiteButton: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.blackColor().CGColor
        
        self.clipsToBounds = true
        
    }
}
