//
//  MypageViewcontroller.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import SnapKit
import Then
import UIKit

class MypageViewcontroller: UIViewController {
  private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then {
    $0.backgroundColor = .systemBackground
    $0.delegate = self
    $0.dataSource = self
    $0.register(UserInfoCell.self, forCellReuseIdentifier: UserInfoCell.identifier)
    $0.register(KickboardRegisterCell.self, forCellReuseIdentifier: KickboardRegisterCell.identifier)
    $0.register(KickboardHistoryCell.self, forCellReuseIdentifier: KickboardHistoryCell.identifier)
  }

  private var isKickboardSectionExpanded = true // 나중에 삭제 예정

  private var kickboardsCount: Int {
    3 // CoreData.count로 나중에 받아옴
  }

  @objc private func toggleSection() {
    isKickboardSectionExpanded.toggle() // 확장 상태 토글
    let indexPaths = (0 ..< kickboardsCount).map { IndexPath(row: $0, section: 1) } // 등록된 킥보드 개수만큼 indexPath 배열 생성 (1번섹션, row 0~N)
    if isKickboardSectionExpanded {
      tableView.insertRows(at: indexPaths, with: .fade)
    } else {
      tableView.deleteRows(at: indexPaths, with: .fade)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  private func configureUI() {
    view.addSubview(tableView)
    view.backgroundColor = .systemBackground
    tableView.separatorStyle = .none

    tableView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

extension MypageViewcontroller: UITableViewDelegate {
  // 0번째 섹션 헤더 높이 설정(0으로)
  func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    section == 0 ? 0 : 32
  }
}

extension MypageViewcontroller: UITableViewDataSource {
  // 셀의 높이를 자동으로
  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }

  // 섹션의 개수를 반환하는 메서드
  func numberOfSections(in _: UITableView) -> Int {
    3
  }

  // 섹션 헤더 커스텀 UIView 사용
  func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let title: String
    switch section {
    case 1: title = "등록한 킥보드"
    case 2: title = "킥보드 이용 내역"
    default: return nil
    }

    let label = UILabel().then {
      $0.text = title
      $0.font = .systemFont(ofSize: 17, weight: .semibold)
      $0.textColor = .secondaryLabel
    }

    let container = UIView()
    container.addSubview(label)

    label.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.bottom.equalToSuperview().inset(4)
    }

    if section == 1 {
      let toggleButton = UIButton(type: .system)
      toggleButton.setTitle("아아~", for: .normal)
      toggleButton.addTarget(self, action: #selector(toggleSection), for: .touchUpInside)
      container.addSubview(toggleButton)
      toggleButton.snp.makeConstraints {
        $0.trailing.equalToSuperview()
        $0.centerY.equalTo(label)
      }
    }

    return container
  }

  // 섹션에 몇 개의 row(셀)이 들어갈지 결정하는 메서드
  func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return isKickboardSectionExpanded ? kickboardsCount : 0
    case 2: return 5
    default: return 0
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier, for: indexPath) as? UserInfoCell else {
        return UITableViewCell()
      }
      return cell

    case 1:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: KickboardRegisterCell.identifier, for: indexPath) as? KickboardRegisterCell else {
        return UITableViewCell()
      }
      return cell

    case 2:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: KickboardHistoryCell.identifier, for: indexPath) as? KickboardHistoryCell else {
        return UITableViewCell()
      }
      return cell

    default:
      return UITableViewCell()
    }
  }
}
