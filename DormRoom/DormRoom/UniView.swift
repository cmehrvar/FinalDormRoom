//
//  UniView.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-02.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class UniView: UIImageView {
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.cornerRadius = (self.bounds.size.width + self.bounds.size.height) / 4
        layer.borderWidth = 1
        layer.borderColor = UIColor.blackColor().CGColor
        self.clipsToBounds = true
    }
}
