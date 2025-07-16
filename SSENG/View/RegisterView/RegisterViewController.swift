//
//  RegisterViewController.swift
//  SSENG
//
//  Created by 이서린 on 7/16/25.
//

import CoreLocation
import UIKit

// MARK: - Model 정의

struct KickBoard {
  let name: String
  let model: String
  let battery: Int
  let latitude: Double
  let longitude: Double
}

// MARK: - 킥보드 등록 관리자

class KickBoardManager {
  private(set) var registered: [KickBoard] = []

  func registerKickBoard(_ kickboard: KickBoard) {
    registered.append(kickboard)
  }
}

// MARK: - 등록 뷰컨트롤러

class RegisterViewController: UIViewController {
  // UI 컴포넌트 (예시로 최소만 구성)
  let nameTextField = UITextField()
  let modelTextField = UITextField()
  let batterySlider = UISlider()

  var currentLat: Double = 37.5665
  var currentLng: Double = 126.9780

  let manager = KickBoardManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupUI()
  }

  private func setupUI() {
    nameTextField.placeholder = "킥보드 이름"
    modelTextField.placeholder = "모델명"
    batterySlider.minimumValue = 0
    batterySlider.maximumValue = 100
    batterySlider.value = 80

    let registerButton = UIButton(type: .system)
    registerButton.setTitle("등록하기", for: .normal)
    registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)

    let stack = UIStackView(arrangedSubviews: [nameTextField, modelTextField, batterySlider, registerButton])
    stack.axis = .vertical
    stack.spacing = 16
    view.addSubview(stack)

    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stack.widthAnchor.constraint(equalToConstant: 250)
    ])
  }

  // 버튼 눌렀을 때 등록 처리
  @objc func registerButtonTapped() {
    let name = nameTextField.text ?? "TestKickboard"
    let model = modelTextField.text ?? "ModelX"
    let battery = Int(batterySlider.value)

    let kickboard = KickBoard(name: name, model: model, battery: battery, latitude: currentLat, longitude: currentLng)

    manager.registerKickBoard(kickboard)
    print("✅ 킥보드 등록 완료: \(kickboard)")
  }
}
