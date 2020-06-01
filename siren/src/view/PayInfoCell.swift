//
//  PayInfoCell.swift
//  siren
//
//  Created by danqin chu on 2020/3/17.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit

final class PayInfoCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.numberOfLines = 2
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let s0 = self.bounds.size
        let s1 = nameLabel.sizeThatFits(s0)
        nameLabel.frame = CGRect(x: 15.0, y: 15.0, width: s0.width, height: s1.height)
        let s2 = timeLabel.sizeThatFits(s0)
        timeLabel.frame = CGRect(x: 15.0, y: s0.height - s2.height - 15.0, width: s0.width, height: s2.height)
    }
    
    func update(with payInfo: PayInfo) {
        let name = payInfo.user
        let time = payInfo.ordertime
        nameLabel.text = "\(name) 「\(payInfo.paytype)」\n订单：\(payInfo.order_id)"
        
        do {
            let timeAttrStr = NSAttributedString(string: time, attributes: [
                .font: UIFont.systemFont(ofSize: 13.0),
                .foregroundColor: UIColor(hex: 0x333333)
            ])
            let statusAttrStr = NSAttributedString(string: payInfo.status.description, attributes: [
                .font: UIFont.systemFont(ofSize: 13.0),
                .foregroundColor: payInfo.status.color
            ])
            let attrStr = NSMutableAttributedString()
            attrStr.append(timeAttrStr)
            attrStr.append(NSAttributedString(string: " "))
            attrStr.append(statusAttrStr)
            timeLabel.attributedText = attrStr
        }
    }
    
}
