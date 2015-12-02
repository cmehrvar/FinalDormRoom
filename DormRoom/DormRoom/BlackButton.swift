//
//  BlackButton.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-11-30.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class BlackButton: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.borderWidth = 2
        layer.borderColor = UIColor.whiteColor().CGColor
        
        self.clipsToBounds = true
        
    }
}
