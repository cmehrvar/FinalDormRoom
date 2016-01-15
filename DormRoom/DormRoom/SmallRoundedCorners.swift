//
//  SmallRoundedCorners.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-14.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class SmallRoundedCorners: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 3
        self.clipsToBounds = true
    }

}
