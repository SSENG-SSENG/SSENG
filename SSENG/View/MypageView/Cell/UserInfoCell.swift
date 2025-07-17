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

  private let userImageView = UIImageView().then {
    $0.image = UIImage(named: "UserDefaultImage")
    $0.contentMode = .scaleAspectFit
  }

  private let userNameLabel = UILabel().then {
    $0.text = "Mori"
  }

  private let statusDotView = UIView().then {
    $0.layer.cornerRadius = 4
    $0.clipsToBounds = true
    $0.backgroundColor = .systemGreen
    // $0.backgroundColor = isRiding ? .systemGreen : .lightGray
  }

  private let statusTextLabel = UILabel().then {
    $0.text = "탑승 중"
    // $0.text = isRiding ? "탑승 중" : "미탑승"
    $0.font = .systemFont(ofSize: 14)
    $0.textColor = .label
  }

  private lazy var ridingStatusStackView = UIStackView(arrangedSubviews: [statusDotView, statusTextLabel]).then {
    $0.axis = .horizontal
    $0.spacing = 6
    $0.alignment = .center
  }

  private let logoutButton = UIButton().then {
    $0.setTitle("로그아웃", for: .normal)
    $0.setTitleColor(.systemRed, for: .normal)
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    configureLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    applyDefaultCardStyle() // 기본 스타일(간격 및 테두리)
    userImageView.layer.cornerRadius = userImageView.frame.width / 2
    userImageView.clipsToBounds = true
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    selectionStyle = .none

    [userImageView, userNameLabel, ridingStatusStackView, logoutButton].forEach { contentView.addSubview($0) }
  }

  private func configureLayout() {
    userImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(16)
      $0.width.height.equalTo(min(UIScreen.main.bounds.width * 0.18, 64)) // 기기 화면 너비의 18%로 자동 조정(최대 64)
    }

    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(userImageView)
      $0.leading.equalTo(userImageView.snp.trailing).offset(16)
      $0.trailing.lessThanOrEqualTo(logoutButton.snp.leading).offset(-8) // 최소 8만큼 떨어지도록
    }

    ridingStatusStackView.snp.makeConstraints {
      $0.top.equalTo(userNameLabel.snp.bottom).offset(8)
      $0.leading.equalTo(userNameLabel)
      $0.trailing.lessThanOrEqualTo(logoutButton.snp.leading).offset(-8)
    }

    statusDotView.snp.makeConstraints {
      $0.width.height.equalTo(10)
    }

    logoutButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-16)
      $0.top.equalTo(userImageView.snp.bottom).offset(-8)
      $0.bottom.equalToSuperview().offset(-8)
      $0.height.equalTo(32)
      $0.width.greaterThanOrEqualTo(60) // width >= 60
    }
  }
}
