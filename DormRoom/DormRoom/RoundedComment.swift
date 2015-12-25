//
//  RoundedComment.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-24.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class RoundedComment: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        self.clipsToBounds = true
    }

}
