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

  private let containerView = UIView()
  private let userImageView = UIImageView().then {
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 42, weight: .semibold)
    let image = UIImage(systemName: "person", withConfiguration: symbolConfig)
    $0.image = image
    $0.tintColor = .main
    $0.contentMode = .center
  }

  private let userNameLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 17, weight: .bold)
  }

  private let statusDotView = UIView().then {
    $0.layer.cornerRadius = 4
    $0.clipsToBounds = true
  }

  private let statusTextLabel = UILabel().then {
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

  // MARK: - layoutSubviews

  override func layoutSubviews() {
    super.layoutSubviews()
    DispatchQueue.main.async {
      self.userImageView.makeCircular()
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - configureUI

  private func configureUI() {
    selectionStyle = .none

    contentView.addSubview(containerView)
    [userImageView, userNameLabel, ridingStatusStackView, logoutButton].forEach { containerView.addSubview($0) }
  }

  // MARK: - configureLayout

  private func configureLayout() {
    containerView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0))
    }

    containerView.layer.cornerRadius = 12
    containerView.layer.borderWidth = 1
    containerView.layer.borderColor = UIColor.lightGray.cgColor
    containerView.backgroundColor = .white

    userImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(16)
      $0.centerY.equalToSuperview()
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
      $0.bottom.equalToSuperview().offset(-8)
      $0.height.equalTo(32)
      $0.width.greaterThanOrEqualTo(60) // width >= 60
    }
  }

  // MARK: - configure

  func configure(_ user: User) {
    userNameLabel.text = user.name

    if user.isRiding {
      statusTextLabel.text = "탑승 중"
      statusDotView.backgroundColor = .systemGreen
    } else {
      statusTextLabel.text = "미탑승"
      statusDotView.backgroundColor = .lightGray
    }
  }
}
