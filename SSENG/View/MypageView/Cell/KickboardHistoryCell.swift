//
//  KickboardHistoryCell.swift
//  SSENG
//
//  Created by 서광용 on 7/16/25.
// 킥보드 이용 내역

import SnapKit
import Then
import UIKit

class KickboardHistoryCell: UITableViewCell {
  static let identifier = "KickboardHistoryCell"
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
