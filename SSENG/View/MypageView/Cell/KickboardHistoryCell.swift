//
//  KickboardHistoryCell.swift
//  SSENG
//
//  Created by 서광용 on 7/16/25.
// 킥보드 이용 내역

import SnapKit
import Then
import UIKit

protocol KickboardHistoryCellDelegate: AnyObject {
  func didTapReportButton(_ cell: KickboardHistoryCell)
}

class KickboardHistoryCell: UITableViewCell {
  static let identifier = "KickboardHistoryCell"

  weak var delegate: KickboardHistoryCellDelegate?

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

  private let reportButton = UIButton().then {
    $0.setImage(UIImage(systemName: "exclamationmark.triangle"), for: .normal)
    $0.tintColor = .systemRed
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
    [kickboardImageView, stackView, reportButton].forEach { containerView.addSubview($0) }
    reportButton.addTarget(self, action: #selector(reportButtonTapped), for: .touchUpInside)
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

    reportButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(8)
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
      let endTime = startTime.addingTimeInterval(TimeInterval(history.duration))
      /// TimeInterval이 Double랑 동일한 의미인데, 시간 계산 때 의도를 명확하게 하려고 관습적(?)으로 사용한다고 한다.
      /// "이건 시간이야"라는 명확한 의도전달을 위해. Double과 기능적 차이 x
      /// addingTimeInterval(_:)는 Date 타입에 초(second) 단위의 Double값을 더해서 새로운 Date를 반환하는 메서드.
      ///
      /// startTime = 2025-07-18 22:00:00 같은 Date타입.
      /// duration = 1800(초)
      /// -> endTime = startTime + 1800초(30분)
      /// -> endTime = 2025-07-18 22:30:00 (자동 계산됨)

      let timeFormatter = DateFormatter()
      timeFormatter.locale = Locale(identifier: "ko_KR")
      timeFormatter.dateFormat = "HH시 mm분 ss초"

      let timeRange = "\(timeFormatter.string(from: startTime)) ~ \(timeFormatter.string(from: endTime))" // "22시02분 ~ 22시43분" 형태로 생셩

      let rideDuration = history.duration // 초 단위 (3665초)
      let rideHour = rideDuration / 3600
      let rideMin = (rideDuration % 3600) / 60
      let rideSec = rideDuration % 60

      var totalDurations: [String] = []
      if rideHour > 0 {
        totalDurations.append("\(rideHour)시간")
      }
      if rideMin > 0 {
        totalDurations.append("\(rideMin)분")
      }
      if rideSec > 0 {
        totalDurations.append("\(rideSec)초")
      }

      let durationString = totalDurations.joined(separator: " ")

      // 최종!! "22시00분00초 ~ 23시01분05초 (1시간1분5초)" 으로 표시됨!!
      timeRangeLabel.text = "\(timeRange) (\(durationString))"
    }
  }

  @objc private func reportButtonTapped() {
    delegate?.didTapReportButton(self)
  }
}
