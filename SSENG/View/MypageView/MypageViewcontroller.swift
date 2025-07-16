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
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  private func setupUI() {
    view.addSubview(tableView)

    tableView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }
}

extension MypageViewcontroller: UITableViewDelegate {}

extension MypageViewcontroller: UITableViewDataSource {
  // 섹션의 개수를 반환하는 메서드
  func numberOfSections(in _: UITableView) -> Int {
    3
  }

  // 섹션의 title을 반환하는 메서드
  func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "1번째 섹션"
    } else if section == 1 {
      return "2번째 섹션"
    } else if section == 2 {
      return "3번째 섹션"
    }
    return nil
  }

  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    5
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = "Section: \(indexPath.section) Row: \(indexPath.row)"
    return cell
  }
}
