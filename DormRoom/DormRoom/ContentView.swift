//
//  ContentView.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-01-20.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class ContentView: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.borderColor = UIColor.grayColor().CGColor
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
}
