//
//  SearchResultCell.swift
//  SSENG
//
//  Created by 이태윤 on 7/20/25.
//
import SnapKit
import Then
import UIKit

class SearchResultCell: UICollectionViewCell {
  static let identifier: String = "SearchResultCell"

  private let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .medium)
    $0.textColor = .label
  }

  private let addressLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .regular)
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 2
  }

  // 셀 초기화 시 UI 요소 등록 및 제약조건 설정
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .secondarySystemBackground
    setupUI()
    setConstraints()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // UI 요소들을 contentView에 추가하는 함수
  private func setupUI() {
    [titleLabel, addressLabel].forEach { contentView.addSubview($0) }
  }

  // SnapKit을 이용해 레이아웃 설정
  private func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(10)
      $0.leading.trailing.equalToSuperview().inset(12)
    }

    addressLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.leading.trailing.equalToSuperview().inset(12)
      $0.bottom.equalToSuperview().inset(10)
    }
  }

  // 전달받은 Place 데이터를 셀 UI에 반영
  func configure(with place: Place) {
    titleLabel.text = place.title.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    addressLabel.text = place.roadAddress.isEmpty ? place.address : place.roadAddress
  }
}
