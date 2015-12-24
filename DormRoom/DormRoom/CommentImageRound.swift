//
//  CommentImageRound.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-24.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentImageRound: UIImageView {

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        self.clipsToBounds = true
    }

}
