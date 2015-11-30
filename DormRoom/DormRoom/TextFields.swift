//
//  TextFields.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-29.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class TextFields: UIView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.clipsToBounds = true
        
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
