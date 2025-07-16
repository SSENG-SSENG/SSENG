//
//  UserInfoCell.swift
//  SSENG
//
//  Created by 서광용 on 7/16/25.
// 사용자 정보

import SnapKit
import Then
import UIKit

class UserInfoCell: UITableViewCell {
  static let identifier = "UserInfoCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
