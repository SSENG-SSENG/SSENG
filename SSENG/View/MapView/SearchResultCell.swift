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

  // 셀이 터치되었을 때 시각적인 하이라이트 효과 적용
  override var isHighlighted: Bool {
    didSet {
      UIView.animate(withDuration: 0.2) {
        // 터치 중일 땐 살짝 축소 + 투명도 낮춤
        self.contentView.alpha = self.isHighlighted ? 0.8 : 1.0
        self.contentView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
      }
    }
  }

  // 셀 초기화 시 UI 요소 등록 및 제약조건 설정
  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = .white
    contentView.layer.cornerRadius = 12
    contentView.layer.shadowColor = UIColor.black.cgColor
    contentView.layer.shadowOpacity = 0.05
    contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
    contentView.layer.shadowRadius = 4
    contentView.layer.masksToBounds = false

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
      $0.top.equalToSuperview().offset(2)
      $0.leading.trailing.equalToSuperview().inset(12)
    }

    addressLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(2)
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
