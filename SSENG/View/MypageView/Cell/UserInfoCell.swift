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
  private let userImageView = UIImageView().then {
    $0.image = UIImage(named: "UserDefaultImage")
    $0.contentMode = .scaleAspectFit
  }

  private let userNameLabel = UILabel().then {
    $0.text = "사용자 이름"
  }

  private let ridingStatusLabel = UILabel().then {
    $0.text = "킥보드 탑승 중" // 이거는 Label로 우선 하고, Image로 변경하던지.. 고민좀
  }

//  private let editButton = UIButton().then {}

  private let logoutButton = UIButton().then {
    $0.setTitle("로그아웃", for: .normal)
    $0.setTitleColor(.systemRed, for: .normal)
  }

  static let identifier = "UserInfoCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
    configureLayout()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    userImageView.layer.cornerRadius = userImageView.frame.width / 2
    userImageView.clipsToBounds = true
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    selectionStyle = .none

    [userImageView, userNameLabel, ridingStatusLabel, logoutButton].forEach { contentView.addSubview($0) }
  }

  private func configureLayout() {
    userImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(16)
      $0.width.height.equalTo(UIScreen.main.bounds.width * 0.18) // 기기 화면 너비의 18%로 자동 조정
    }

    userNameLabel.snp.makeConstraints {
      $0.top.equalTo(userImageView)
      $0.leading.equalTo(userImageView.snp.trailing).offset(16)
      $0.trailing.lessThanOrEqualTo(logoutButton.snp.leading).offset(-8) // 최소 8만큼 떨어지도록
    }

    ridingStatusLabel.snp.makeConstraints {
      $0.top.equalTo(userNameLabel.snp.bottom).offset(8)
      $0.leading.equalTo(userNameLabel)
      $0.trailing.lessThanOrEqualTo(logoutButton.snp.leading).offset(-8)
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
