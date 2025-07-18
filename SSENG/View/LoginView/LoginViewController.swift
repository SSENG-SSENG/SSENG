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
    // $0.image = UIImage(named: "LogoCroped")
    $0.contentMode = .scaleAspectFit
  }

  private let idLabel = UILabel().then {
    $0.text = "아이디"
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
  }

  private let pwLabel = UILabel().then {
    $0.text = "비밀번호"
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
  }

  private let loginButton = UIButton().then {
    $0.setTitle("로그인", for: .normal)
    $0.setTitleColor(.main, for: .normal)
  }

  private let signUpBUtton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.setTitleColor(.main, for: .normal)
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

    // loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    signUpBUtton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    // debugButton.addTarget(self, action: #selector(donttouchthis), for: .touchUpInside)
  }

  func setupUI() {
    [appLogoImageView, idStackView, pwStackView, loginButton, signUpBUtton].forEach {
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
    appLogoImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.centerX.equalToSuperview()
      // $0.width.height.equalTo(100) // 로고 크기 조정
    }

    idStackView.snp.makeConstraints {
      $0.top.equalTo(appLogoImageView.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(80)
      $0.centerX.equalToSuperview()
    }

    pwStackView.snp.makeConstraints {
      $0.top.equalTo(idStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(80)
      $0.centerX.equalToSuperview()
    }

    loginButton.snp.makeConstraints {
      $0.top.equalTo(pwStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(80)
      $0.centerX.equalToSuperview()

    }

    signUpBUtton.snp.makeConstraints {
      $0.top.equalTo(loginButton.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(80)
      $0.centerX.equalToSuperview()

    }
  }

  @objc func didTapLogin() {
    // let mapVC = MapViewController()
    // navigationController?.pushViewController(mapVC, animated: true)
  }

  @objc func didTapSignUp() {
    let signUpVC = SignViewController()
    navigationController?.pushViewController(signUpVC, animated: true)
  }

  @objc func donttouchthis() {
    CoreDataStack.shared.deleteAllData()
  }
}
