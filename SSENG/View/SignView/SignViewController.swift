//
//  SignViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import SnapKit
import Then
import UIKit

class SignViewController: UIViewController {
  // MARK: 컴포넌트 초기화

  // |=============|
  // |---앱 로고---|
  // |아이디 레이블|
  // |-아이디 텍박-|
  // |-비번 레이블-|
  // |--비번 텍박--|
  // |재확인 레이블|
  // |-재확인 텍박-|
  // |닉네임 레이블|
  // |-닉네임 텍박-|
  // |체크박스|약관|
  // |--가입 버튼--|
  // |=============|

  private let appLogoImageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }

  private let idLabel = UILabel().then {
    $0.text = "아이디"
  }

  private let idTextField = UITextField().then {
    $0.placeholder = "아이디를 입력하세요."
    // TODO: 띄어쓰기 등 아이디 표준 정규표현식 적용하기
  }

  private let idStackView = UIStackView().then {
    $0.axis = .vertical
  }

  private let pwLabel = UILabel().then {
    $0.text = "비밀번호"
  }

  private let pwTextField = UITextField().then {
    $0.placeholder = "비밀번호를 입력하세요."
    // TODO: 띄어쓰기 등 비밀번호 표준 정규표현식 적용하기
  }

  private let pwStackView = UIStackView().then {
    $0.axis = .vertical
  }

  private let rePwLabel = UILabel().then {
    $0.text = "비밀번호 재확인"
  }

  private let rePwTextField = UITextField().then {
    $0.placeholder = "비밀번호를 다시 입력하세요."
    // TODO: pwTextField와 같은 건지 확인 절차 적용하기
  }

  private let rePwStackView = UIStackView().then {
    $0.axis = .vertical
  }

  private let nickNameLabel = UILabel().then {
    $0.text = "닉네임"
  }

  private let nickNameTextField = UITextField().then {
    $0.placeholder = "닉네임 최대"
  }

  private let nickNameViewStack = UIStackView().then {
    $0.axis = .vertical
  }

  private let termsAgreeCheckBox = UIButton(type: .custom).then {
    $0.setImage(UIImage(named: "uncheck"), for: .normal)
    $0.setImage(UIImage(named: "check"), for: .selected)
  }

  private let termsViewButton = UIButton(type: .system).then {
    $0.setTitle("이용약관", for: .normal)
  }

  private let termsTextLabel = UILabel().then {
    $0.text = "에 동의합니다."
  }

  private let termsStackView = UIStackView().then {
    $0.axis = .horizontal
  }

  private let submitButton = UIButton(type: .system).then {
    $0.setTitle("가입하기", for: .normal)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    setupUI()
    setupConstraints()
    setupButtonActions()
  }

  // 뷰, 스택
  private func setupUI() {
    [
      appLogoImageView,
      idStackView,
      pwStackView,
      rePwStackView,
      nickNameViewStack,
      termsStackView,
      submitButton
    ].forEach {
      view.addSubview($0)
    }

    for item in [idLabel, idTextField] {
      idStackView.addArrangedSubview(item)
    }

    for item in [pwLabel, pwTextField] {
      pwStackView.addArrangedSubview(item)
    }

    for item in [rePwLabel, rePwTextField] {
      rePwStackView.addArrangedSubview(item)
    }

    for item in [nickNameLabel, nickNameTextField] {
      nickNameViewStack.addArrangedSubview(item)
    }

    for item in [termsAgreeCheckBox, termsViewButton, termsTextLabel] {
      termsStackView.addArrangedSubview(item)
    }
  }

  // 컴포넌트 레이아웃
  private func setupConstraints() {
    // appLogoImageView.snp.makeConstraints {
    //   $0.top.equalTo(view.safeAreaLayoutGuide)
    //   $0.trailing.leading.equalToSuperview()
    // }

    idStackView.snp.makeConstraints {
      // $0.top.equalTo(appLogoImageView.snp.bottom)
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    pwStackView.snp.makeConstraints {
      $0.top.equalTo(idStackView.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    rePwStackView.snp.makeConstraints {
      $0.top.equalTo(pwStackView.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    nickNameViewStack.snp.makeConstraints {
      $0.top.equalTo(rePwStackView.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    termsStackView.snp.makeConstraints {
      $0.top.equalTo(nickNameLabel.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    submitButton.snp.makeConstraints {
      $0.top.equalTo(termsStackView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
    }
  }

  // 버튼 기능 초기화
  private func setupButtonActions() {
    // TODO:
  }

  // MARK: 버튼 팡숀
}
