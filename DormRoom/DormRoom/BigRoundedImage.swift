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
        layer.cornerRadius = 32
        self.clipsToBounds = true
    }
}
