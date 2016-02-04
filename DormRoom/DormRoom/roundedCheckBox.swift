//
//  roundedCheckBox.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2016-02-03.
//  Copyright © 2016 Cina Mehrvar. All rights reserved.
//

import UIKit

class roundedCheckBox: UIView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        self.clipsToBounds = true
    }

}
