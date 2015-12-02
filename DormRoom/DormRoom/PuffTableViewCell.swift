//
//  PuffTableViewCell.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-01.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class PuffTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var ImageOutlet: UIImageView!
    @IBOutlet weak var LikeOutlet: UILabel!
    @IBOutlet weak var DislikeOutlet: UILabel!
    @IBOutlet weak var CaptionOutlet: UILabel!
    @IBOutlet weak var UniversityOutlet: UIImageView!
    @IBOutlet weak var ProfileOutlet: UIImageView!
    @IBOutlet weak var SwipeViewOutlet: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
