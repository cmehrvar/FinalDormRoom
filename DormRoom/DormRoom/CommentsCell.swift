//
//  CommentsCell.swift
//  DormRoom
//
//  Created by Cina Mehrvar on 2015-12-22.
//  Copyright © 2015 Cina Mehrvar. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

 
    @IBOutlet weak var CommentProfile: RoundedImage!
    @IBOutlet weak var WorkingLabel: UILabel!
    @IBOutlet weak var TimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
