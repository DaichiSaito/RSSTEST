//
//  YoutubeTableViewCell.swift
//  RSSTEST
//
//  Created by DaichiSaito on 2018/01/28.
//  Copyright © 2018年 Orfool inc. All rights reserved.
//

import UIKit

class YoutubeTableViewCell: UITableViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(feed: Feed) {
        self.titleLabel.text = feed.title
        self.myImageView.contentMode = .scaleAspectFill
        self.myImageView.clipsToBounds = true
        if let url = feed.imagePath {
            self.myImageView.af_setImage(withURL: URL(string: url)!, placeholderImage: UIImage(named: "NoImage")) { image -> Void in
                
                
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy/MM/dd HH:mm", options: 0, locale: Locale(identifier: "ja_JP"))
                print(formatter.string(from: Date())) // 2017年8月12日
        self.createdAtLabel.text = formatter.string(from: feed.createdAt)
        
    }

}
