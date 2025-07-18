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

  private let containerView = UIView()

  private let kickboardImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
    $0.image = UIImage(named: "kickboardPadding") // 예시 이미지
  }

  private let uuidLabel = UILabel().then {
    $0.text = "uuid 값"
    $0.font = .systemFont(ofSize: 14, weight: .medium)
    $0.textColor = .label
  }

  private let usageTimeLabel = UILabel().then { // 킥보드 이용 날짜 및 시간
    $0.text = """
    2025년 09월 02일
    14시34분 ~ 15시50분 (1시간 16분)
    """
    $0.font = .systemFont(ofSize: 13)
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 0
  }

  private lazy var stackView = UIStackView(arrangedSubviews: [uuidLabel, usageTimeLabel]).then {
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
}
