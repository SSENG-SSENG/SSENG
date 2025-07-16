//
//  RegisterViewController.swift
//  SSENG
//
//  Created by 이서린 on 7/16/25.
//

import CoreLocation
import UIKit

class RegisterViewController: UIViewController {
  // MARK: - UI Components

  private let typeTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "킥보드 타입 (숫자)"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .numberPad
    return textField
  }()

  private let latitudeField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "위도 (예: 37.5665)"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    return textField
  }()

  private let longitudeField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "경도 (예: 126.9780)"
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    return textField
  }()

  private lazy var registerButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("킥보드 등록", for: .normal)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    return button
  }()

  private lazy var stackView: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [
      typeTextField,
      latitudeField,
      longitudeField,
      registerButton
    ])
    stack.axis = .vertical
    stack.spacing = 16
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  // MARK: - Properties

  private let repository = KickboardRepository()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupUI()
  }

  // MARK: - UI Setup

  private func setupUI() {
    view.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
      stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
      registerButton.heightAnchor.constraint(equalToConstant: 44)
    ])
  }

  // MARK: - Actions

  @objc private func registerButtonTapped() {
    guard let typeText = typeTextField.text, !typeText.isEmpty, let type = Int16(typeText) else {
      showAlert(title: "입력 오류", message: "올바른 킥보드 타입을 입력해주세요.")
      return
    }

    guard let latText = latitudeField.text, !latText.isEmpty, let lat = Double(latText) else {
      showAlert(title: "입력 오류", message: "올바른 위도를 입력해주세요.")
      return
    }

    guard let lngText = longitudeField.text, !lngText.isEmpty, let lng = Double(lngText) else {
      showAlert(title: "입력 오류", message: "올바른 경도를 입력해주세요.")
      return
    }

    registerKickboard(type: type, latitude: lat, longitude: lng)
  }

  // MARK: - Helpers

  private func clearTextFields() {
    typeTextField.text = nil
    latitudeField.text = nil
    longitudeField.text = nil
  }

  private func registerKickboard(type: Int16, latitude: Double, longitude: Double) {
    let locationString = "\(latitude)/\(longitude)"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let nowString = dateFormatter.string(from: Date())

    let newID = repository.registKickboard(
      registerDate: nowString,
      location: locationString,
      detailLocation: "", // 상세 위치는 빈 문자열로 전달
      type: type
    )

    print("✅ 킥보드 등록 완료: ID=\(newID), 위치=\(locationString), 타입=\(type)")

    let successMessage = """
    새로운 킥보드가 성공적으로 등록되었습니다.
    ID: \(newID)
    """
    showAlert(title: "등록 완료", message: successMessage) { [weak self] in
      self?.clearTextFields()
    }
  }

  private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
      completion?()
    })
    present(alert, animated: true)
  }
}
