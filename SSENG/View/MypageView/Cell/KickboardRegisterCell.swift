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

  private let containerView = UIView()

  private let kickboardImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }

  private let uuidLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .medium)
    $0.textColor = .label
  }

  private let registerDateTimeLabel = UILabel().then { // 킥보드 등록 날짜 및 시간
    $0.font = .systemFont(ofSize: 13)
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 0
  }

  private lazy var stackView = UIStackView(arrangedSubviews: [uuidLabel, registerDateTimeLabel]).then {
    $0.axis = .vertical
    $0.spacing = 4
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
      self.kickboardImageView.makeCircular()
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
    [kickboardImageView, stackView].forEach { containerView.addSubview($0) }
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

    kickboardImageView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(16)
      $0.width.height.equalTo(min(UIScreen.main.bounds.width * 0.14, 48)) // 기기 화면 너비의 14%로 자동 조정(최대 48)
      $0.bottom.lessThanOrEqualToSuperview().offset(-16) // 최소 16 떨어져야함
    }

    stackView.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalTo(kickboardImageView.snp.trailing).offset(12)
      $0.trailing.equalToSuperview().offset(-16)
    }
  }

  // MARK: - configure

  func configure(_ kickboard: Kickboard) {
    uuidLabel.text = kickboard.id.map { String($0.prefix(8)) } // UUID는 앞에 8글자만 보여줌

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy년 MM월 dd일"

    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH시 mm분"

    if let registerDateStr = kickboard.registerDate,
       let registerDate = registerDateStr.toDate()
    { // "2025-07-18 14:35:00"
      let dateString = dateFormatter.string(from: registerDate) // "2025년 07월 18일"
      let timeString = timeFormatter.string(from: registerDate) // "14시 35분"

      registerDateTimeLabel.text = """
      \(dateString)
      \(timeString)
      """
    }

    if let kickboardType = kickboard.kickboardType {
      let imageName: String
      switch kickboardType {
      case .bike:
        imageName = "bikePadding"
      case .kickboard:
        imageName = "kickboardPadding"
      }
      kickboardImageView.image = UIImage(named: imageName)
    }
  }
}

extension String {
  // 문자열(String) -> Date로 변환
  func toDate() -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.date(from: self)
  }
}
