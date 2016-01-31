//
//  BigRoundedImage.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-29.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class BigRoundedImage: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 38
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayColor().CGColor
        self.clipsToBounds = true
    }
}
