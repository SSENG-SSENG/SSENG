//
//  ViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import SnapKit
import Then
import UIKit

class LoginViewController: UIViewController {
  private let appLogoImageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }

  private let idLabel = UILabel().then {
    $0.text = "아이디"
    $0.font = .systemFont(ofSize: 15, weight: .medium)
  }

  private let idTextField = UITextField().then {
    $0.placeholder = "아이디를 입력하세요."
    $0.keyboardType = .asciiCapable
    $0.textContentType = .none
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.smartInsertDeleteType = .no
    $0.autocapitalizationType = .none
    $0.clearButtonMode = .always
    $0.returnKeyType = .next
  }

  private let idStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6
  }

  private let pwLabel = UILabel().then {
    $0.text = "비밀번호"
    $0.font = .systemFont(ofSize: 15, weight: .medium)
  }

  private let pwTextField = UITextField().then {
    $0.placeholder = "비밀번호를 입력하세요."
    $0.textContentType = .password
    $0.clearButtonMode = .always
    $0.isSecureTextEntry = true
    $0.returnKeyType = .next
  }

  private let pwStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6
  }

  private let loginButton = UIButton().then {
    $0.setTitle("로그인", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .main
    $0.layer.cornerRadius = 8
  }

  private let signUpBUtton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.setTitleColor(.main, for: .normal)
    $0.backgroundColor = .white
    $0.layer.borderColor = UIColor.main.cgColor
    $0.layer.borderWidth = 3
    $0.layer.cornerRadius = 8
  }

  private let debugButton = UIButton().then {
    $0.setTitle("주의! 디버그!", for: .normal)
    $0.setTitleColor(.main, for: .normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupUI()
    setupConstraints()
    setupBUttonActions()
    updateLoginButtonState()
    addTextFieldObsevers()
  }

  func setupUI() {
    [appLogoImageView, idStackView, pwStackView, loginButton, signUpBUtton, debugButton].forEach {
      view.addSubview($0)
    }

    [idLabel, idTextField].forEach {
      idStackView.addArrangedSubview($0)
    }

    [pwLabel, pwTextField].forEach {
      pwStackView.addArrangedSubview($0)
    }
  }

  func setupConstraints() {
    let padding: CGFloat = 60
    let height: CGFloat = 48

    appLogoImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(padding)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(120)
    }

    idTextField.snp.makeConstraints {
      $0.height.equalTo(height)
    }

    idStackView.snp.makeConstraints {
      $0.top.equalTo(appLogoImageView.snp.bottom).offset(56)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.centerX.equalToSuperview()
    }

    pwTextField.snp.makeConstraints {
      $0.height.equalTo(height)
    }

    pwStackView.snp.makeConstraints {
      $0.top.equalTo(idStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.centerX.equalToSuperview()
    }

    loginButton.snp.makeConstraints {
      $0.top.equalTo(pwStackView.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.height.equalTo(height)
      $0.centerX.equalToSuperview()

    }

    signUpBUtton.snp.makeConstraints {
      $0.top.equalTo(loginButton.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.height.equalTo(height)
      $0.centerX.equalToSuperview()
    }

    debugButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(10)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.centerX.equalToSuperview()
    }
  }

  private func setupBUttonActions() {
    loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    signUpBUtton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    debugButton.addTarget(self, action: #selector(donttouchthis), for: .touchUpInside)
  }

  private func addTextFieldObsevers() {
    [idTextField, pwTextField].forEach {
      $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
  }

  private func updateLoginButtonState() {
    let id = idTextField.text ?? ""
    let pw = pwTextField.text ?? ""
    let allVAlid = isValidID(id) && isValidPW(pw)

    loginButton.isEnabled = allVAlid
    loginButton.alpha = allVAlid ? 1.0 : 0.5
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
    -> Bool
  {
    guard let t = textField.text as NSString? else { return true }
    let updated = t.replacingCharacters(in: range, with: string)
    switch textField {
    case idTextField:
      return updated.count <= 16
        && (string.isEmpty || string.range(of: "[^a-z0-9]", options: .regularExpression) == nil)
    case pwTextField:
      return updated.count <= 32
    default:
      return true
    }
  }

  private func isValidID(_ id: String) -> Bool {
    id.range(of: #"^[a-z0-9]{4,16}$"#, options: .regularExpression) != nil
  }

  private func isValidPW(_ pw: String) -> Bool {
    pw.range(of: #"^[A-Za-z\d!@#$&*]{8,32}$"#, options: .regularExpression) != nil
  }

  func alertController(on vc: UIViewController, title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    vc.present(alert, animated: true)
  }

  @objc func didTapLogin() {
    if UserRepository().readUser(by: idTextField.text ?? "id-xxxx")?.id != idTextField.text {
      alertController(on: self, title: "아이디 오류", message: "해당 아이디가 존재하지 않습니다.")
    }

    if UserRepository().readUser(by: idTextField.text ?? "pw-xxxx")?.password != pwTextField.text {
      alertController(on: self, title: "비밀번호 오류", message: "비밀번호가 일치하지 않습니다.")
    }

    let mapVC = MapViewController()
    navigationController?.pushViewController(mapVC, animated: true)
  }

  @objc func didTapSignUp() {
    let signUpVC = SignViewController()
    navigationController?.pushViewController(signUpVC, animated: true)
  }

  @objc func donttouchthis() {
    // CoreDataStack.shared.deleteAllData()
    print(UserRepository().readUser(by: idTextField.text ?? "no id")?.password ?? "비밀번호 없음?!")
  }

  @objc private func textFieldDidChange(_ textField: UITextField) {
    switch textField {
    case idTextField:
      if let text = textField.text {
        let filtered = text.lowercased().filter { $0.isLetter || $0.isNumber }
        textField.text = String(filtered.prefix(16))
      }

    case pwTextField:
      if let text = textField.text, text.count > 32 {
        textField.text = String(text.prefix(32))
      }
    default:
      break
    }
    updateLoginButtonState()
  }
}
