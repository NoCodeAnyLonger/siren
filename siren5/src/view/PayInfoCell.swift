//
//  PayInfoCell.swift
//  siren
//
//  Created by danqin chu on 2020/3/17.
//  Copyright © 2020 danqin chu. All rights reserved.
//

import UIKit

final class PayInfoCell: UITableViewCell {
    
    struct Pref {
        static let padding = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
        static let spacing0: CGFloat = 15.0
    }
    
    private static let shared = PayInfoCell(style: .default, reuseIdentifier: nil)
    
    private let nameLabel = UILabel()
    
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        nameLabel.numberOfLines = 0
        self.contentView.addSubview(nameLabel)
        
        self.contentView.addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding = Pref.padding
        let r0 = self.bounds
        let r1 = r0.inset(by: padding)
        
        let s1 = nameLabel.sizeThatFits(r1.size)
        let nameLabelFrame = CGRect(x: padding.left, y: padding.top, width: s1.width, height: s1.height)
        nameLabel.frame = nameLabelFrame
        
        let s2 = timeLabel.sizeThatFits(r1.size)
        timeLabel.frame = CGRect(x: padding.left, y: r1.maxY - s2.height, width: s2.width, height: s2.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let padding = Pref.padding
        let s0 = CGSize(width: size.width - padding.left - padding.right, height: size.height)
        
        let nameLabelSize = nameLabel.sizeThatFits(s0)
        
        let timeLabelSize = timeLabel.sizeThatFits(s0)
        
        let height = padding.top + nameLabelSize.height + Pref.spacing0 + timeLabelSize.height + padding.bottom
        return CGSize(width: size.width, height: height)
    }
    
    func update(with payInfo: PayInfo) {
        let name = payInfo.user
        let time = payInfo.ordertime
        nameLabel.text = """
        \(name) 「\(payInfo.paytype)」
        订单：\(payInfo.order_id)
        商品：\(payInfo.title)
        价格：\(payInfo.money)
        """
        
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
        self.setNeedsLayout()
    }
    
}

extension PayInfoCell {
    
    static func fitSize(size: CGSize, for payInfo: PayInfo) -> CGSize {
        shared.update(with: payInfo)
        return shared.sizeThatFits(size)
    }
    
}
