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
  private let loginButton = UIButton().then {
    $0.setTitle("로그인", for: .normal)
    $0.setTitleColor(.main, for: .normal)
  }
  
  private let signUpBUtton = UIButton().then {
    $0.setTitle("회원가입", for: .normal)
    $0.setTitleColor(.main, for: .normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupUI()
    setupConstraints()
    
    loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    signUpBUtton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
  }

  func setupUI() {
    [loginButton, signUpBUtton].forEach(view.addSubview)
  }

  func setupConstraints() {
    loginButton.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
    }
    signUpBUtton.snp.makeConstraints {
      $0.top.equalTo(loginButton.snp.bottom)
      $0.leading.trailing.equalToSuperview()
    }
  }

  @objc func didTapLogin() {
    let mapVC = MapViewController()
    navigationController?.pushViewController(mapVC, animated: true)
  }
  
  @objc func didTapSignUp() {
    let signUpVC = SignViewController()
    navigationController?.pushViewController(signUpVC, animated: true)
  }
}
