//
//  RoundedLogIn.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-02-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class RoundedLogIn: UIView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
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
