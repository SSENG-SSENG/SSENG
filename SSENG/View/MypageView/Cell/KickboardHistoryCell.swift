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

  private let dateLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 14, weight: .medium)
    $0.textColor = .label
  }

  private let timeRangeLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 13)
    $0.textColor = .secondaryLabel
    $0.numberOfLines = 0
  }

  private lazy var stackView = UIStackView(arrangedSubviews: [dateLabel, timeRangeLabel]).then {
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

  func configure(_ history: History) {
    if history.type == KickboardType.bike.rawValue {
      kickboardImageView.image = UIImage(named: "bikePadding")
    } else {
      kickboardImageView.image = UIImage(named: "kickboardPadding")
    }

    // 탑승 시간 포맷 ("2025-07-18 22:43:00" -> "2025년 07월 18일"
    if let startTime = history.startTime?.toDate() { // Date 타입 변환
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "ko_KR")
      dateFormatter.dateFormat = "yyyy년 MM월 dd일"
      dateLabel.text = dateFormatter.string(from: startTime)

      // 시작 시간(startTime)부터 총 이용 시간(duration)을 더해서 종료 시간(endTime) 계산
      let endTime = startTime.addingTimeInterval(TimeInterval(history.duration * 60))
      /// TimeInterval이 Double랑 동일한 의미인데, 시간 계산 때 의도를 명확하게 하려고 관습적(?)으로 사용한다고 한다.
      /// "이건 시간이야"라는 명확한 의도전달을 위해. Double과 기능적 차이 x
      /// addingTimeInterval(_:)는 Date 타입에 초(second) 단위의 Double값을 더해서 새로운 Date를 반환하는 메서드.
      ///
      /// startTime = 2025-07-18 22:00:00 같은 Date타입.
      /// duration = 30(분)
      /// -> endTime = startTime + 1800초(30분)
      /// -> endTime = 2025-07-18 22:30:00 (자동 계산됨)

      let timeFormatter = DateFormatter()
      timeFormatter.locale = Locale(identifier: "ko_KR")
      timeFormatter.dateFormat = "HH시mm분"

      let timeRange = "\(timeFormatter.string(from: startTime)) ~ \(timeFormatter.string(from: endTime))" // "22시02분 ~ 22시43분" 형태로 생셩

      let durationHour = history.duration / 60 // 시간 분리 (90 / 60 -> 1시간)
      let durationMin = history.duration % 60 // 분 분리 (90 % 60 -> 30분)

      // 시간, 분 조합해서 "1시간 10분" or "47분" 이런 형식으로 사용
      let durationString = "(\(durationHour > 0 ? "\(durationHour)시간 " : "")\(durationMin)분)"

      // 최종!! "22시02분 ~ 22시43분 (41분)" 으로 표시됨!!
      timeRangeLabel.text = "\(timeRange) \(durationString)"
    }
  }
}
