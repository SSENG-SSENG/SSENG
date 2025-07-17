//
//  KickboardRegisterCell.swift
//  SSENG
//
//  Created by 서광용 on 7/16/25.
// 등록한 킥보드

import SnapKit
import Then
import UIKit

class KickboardRegisterCell: UITableViewCell {
  static let identifier = "KickboardRegisterCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    applyDefaultCardStyle() // 기본 스타일(간격 및 테두리)
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    selectionStyle = .none
  }
}
