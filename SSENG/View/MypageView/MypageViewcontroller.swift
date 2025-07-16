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
    $0.delegate = self
    $0.dataSource = self
    $0.register(UserInfoCell.self, forCellReuseIdentifier: UserInfoCell.identifier)
    $0.register(KickboardRegisterCell.self, forCellReuseIdentifier: KickboardRegisterCell.identifier)
    $0.register(KickboardHistoryCell.self, forCellReuseIdentifier: KickboardHistoryCell.identifier)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
  }

  private func configureUI() {
    view.addSubview(tableView)
    view.backgroundColor = .systemBackground

    tableView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

extension MypageViewcontroller: UITableViewDelegate {}

extension MypageViewcontroller: UITableViewDataSource {
  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }

  // 섹션의 개수를 반환하는 메서드
  func numberOfSections(in _: UITableView) -> Int {
    3
  }

  // 섹션의 title을 반환하는 메서드
  func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 1: return "등록한 킥보드"
    case 2: return "킥보드 이용 내역"
    default: return nil
    }
  }

  // 섹션에 몇 개의 row(셀)이 들어갈지 결정하는 메서드
  func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return 2
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
