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

  private var section1ToggleButton: UIButton?
  private var isKickboardSectionExpanded = true // 나중에 삭제 예정

  private var user: User? // CoreData에서 가져온 유저 정보
  private let userRepository = UserRepository() // User 정보 가져올 때 사용

  private var kickboards: [Kickboard] = [] // CoreData에서 가져온 킥보드 리스트
  private let kickboardRepository = KickboardRepository() // CoreData에서 킥보드 정보 가져올 때 사용

  // 등록된 킥보드 개수
  private var kickboardsCount: Int {
    kickboards.count
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//     signAndLoginTest() // 테스트 데이터 생성
//     registerKickboardTest() // 테스트 데이터 생성
    configureUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchUserData()
    fetchKickboardData()
  }

  // MARK: - 회원가입/로그인 임시 테스트 (작동 확인함)

//
//    private func signAndLoginTest() {
//      let userID = "Mori"
//      if userRepository.readUser(by: userID) == nil {
//        userRepository.createUser(id: userID, name: "서광용", password: "1234")
//      }
//
//      // 임시 로그인
//      UserDefaults.standard.set(userID, forKey: "loggedUserID")
//    }

  // MARK: - 등록한 킥보드 임시 테스트 (테스트 완료)

//
//    private func registerKickboardTest() {
//      let context = CoreDataStack.shared.context
//
//      // 킥보드 1 (bike 타입)
//      let kickboard1 = Kickboard(context: context)
//      kickboard1.type = KickboardType.bike.rawValue
//      kickboard1.registerDate = "2025-07-18 17:00:00"
//      kickboard1.id = UUID().uuidString
//
//      // 킥보드 2 (kickboard 타입)
//      let kickboard2 = Kickboard(context: context)
//      kickboard2.type = KickboardType.kickboard.rawValue
//      kickboard2.registerDate = "2025-07-18 17:10:00"
//      kickboard2.id = UUID().uuidString
//
//      // 킥보드 3 (bike 타입)
//      let kickboard3 = Kickboard(context: context)
//      kickboard3.type = KickboardType.bike.rawValue
//      kickboard3.registerDate = "2025-07-18 17:20:00"
//      kickboard3.id = UUID().uuidString
//
//      // 공통: 현재 로그인된 사용자 ID 설정
//      guard let userID = UserDefaults.standard.string(forKey: "loggedUserID") else {
//        print("로그인된 사용자 ID가 없습니다.")
//        return
//      }
//      for item in [kickboard1, kickboard2, kickboard3] {
//        item.registerId = userID
//      }
//
//      CoreDataStack.shared.saveContext()
//      print("테스트 킥보드 3개 등록 완료")
//    }

  // MARK: - 유저 데이터 불러오기

  private func fetchUserData() {
    guard let userID = UserDefaults.standard.string(forKey: "loggedUserID") else { // forKey값은 바뀌면 수정. 임시임
      print("로그인이 잘 되지 않았습니다.")
      return
    }

    user = userRepository.readUser(by: userID) // userID를 통해 CoreData에서 읽어옴

    if user == nil {
      print("CoreData에 해당 ID를 가진 사용자는 없는걸요..? 어찌 로그인 하셨담.. 해커세요?")
    } else {
      print("CoreData에 해당 ID를 가진 사용자가 있네요! \(user?.name ?? "")님 환영합니다~")
    }
  }

  // MARK: - 등록된 킥보드 데이터 불러오기

  private func fetchKickboardData() {
    guard let userID = UserDefaults.standard.string(forKey: "loggedUserID") else {
      print("등록된 킥보드를 불러오지 못했습니다.")
      return
    }

    kickboards = kickboardRepository.readRegistedKickboard(by: userID)
    print("불러온 킥보드 개수: \(kickboards.count)")
  }

  // MARK: - configureUI

  private func configureUI() {
    view.addSubview(tableView)
    view.backgroundColor = .systemBackground
    tableView.separatorStyle = .none

    tableView.snp.makeConstraints {
      $0.directionalEdges.equalTo(view.safeAreaLayoutGuide)
    }
  }

  // 등록한 킥보드 섹션을 열거나 접는 동작
  @objc private func toggleSection() {
    isKickboardSectionExpanded.toggle() // 확장 상태 토글

    let indexPaths = (0 ..< kickboardsCount).map { IndexPath(row: $0, section: 1) } // 현재 섹션의 셀 위치들을 미리 만듦
    if isKickboardSectionExpanded {
      tableView.insertRows(at: indexPaths, with: .fade)
    } else {
      tableView.deleteRows(at: indexPaths, with: .fade)
    }

    let iconName = isKickboardSectionExpanded ? "chevron.down" : "chevron.right"
    section1ToggleButton?.setImage(UIImage(systemName: iconName), for: .normal)
  }
}

// MARK: - UITableViewDelegate

extension MypageViewcontroller: UITableViewDelegate {
  // 0번째 섹션 헤더 높이 설정(0으로)
  func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    section == 0 ? 0 : 32
  }
}

// MARK: - UITableViewDataSource

extension MypageViewcontroller: UITableViewDataSource {
  // 셀 높이는 자동으로 계산되도록 (AutoLayout 기반)
  func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }

  // 섹션의 개수를 반환 (유저 정보 / 등록한 킥보드 / 이용 내역)
  func numberOfSections(in _: UITableView) -> Int {
    3
  }

  // 각 섹션에 맞는 헤더 타이틀 설정
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

    // 등록한 킥보드 섹션에만 토글 버튼 추가
    if section == 1 {
      let toggleButton = UIButton(type: .system)
      let iconName = isKickboardSectionExpanded ? "chevron.down" : "chevron.left"
      toggleButton.setImage(UIImage(systemName: iconName), for: .normal)
      toggleButton.tintColor = .secondaryLabel
      toggleButton.addTarget(self, action: #selector(toggleSection), for: .touchUpInside)

      section1ToggleButton = toggleButton // 상태 저장

      container.addSubview(toggleButton)

      toggleButton.snp.makeConstraints {
        $0.trailing.equalToSuperview()
        $0.centerY.equalTo(label)
      }
    }

    return container
  }

  // 각 섹션에 몇 개의 row(셀)이 들어갈지 결정하는 메서드
  func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0: return 1
    case 1: return isKickboardSectionExpanded ? kickboardsCount : 0
    case 2: return 5
    default: return 0
    }
  }

  // 각 섹션에 맞는 셀을 반환
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: UserInfoCell.identifier, for: indexPath) as? UserInfoCell else {
        return UITableViewCell()
      }
      if let user {
        cell.configure(user)
      }

      return cell

    case 1:
      guard let cell = tableView.dequeueReusableCell(withIdentifier: KickboardRegisterCell.identifier, for: indexPath) as? KickboardRegisterCell else {
        return UITableViewCell()
      }
      let kickboard = kickboards[indexPath.row] // 현재 row에 맞는 데이터 가져오기
      cell.configure(kickboard)
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
