//
//  CommentProfile.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-30.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentProfile: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayColor().CGColor
        self.clipsToBounds = true
    }
}
