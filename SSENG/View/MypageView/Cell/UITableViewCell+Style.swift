//
//  UITableViewCell+Style.swift
//  SSENG
//
//  Created by 서광용 on 7/17/25.
//

import UIKit

extension UITableViewCell {
  func applyDefaultCardStyle() {
    contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    contentView.layer.cornerRadius = 12
    contentView.layer.borderWidth = 1.5
    contentView.layer.borderColor = UIColor.lightGray.cgColor
    contentView.layer.masksToBounds = true
  }
}
