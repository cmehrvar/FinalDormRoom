//
//  SwipeView.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-02.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class SwipeView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 30
        layer.borderWidth = 5
        layer.borderColor = UIColor.blackColor().CGColor
        self.clipsToBounds = true
    }


}
