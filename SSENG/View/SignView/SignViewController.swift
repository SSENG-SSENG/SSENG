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
  // 동의 여부
  private var isAgreed = false
  private let repository = UserRepository()


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

  // MARK: 컴포넌트 초기화
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
    $0.isSecureTextEntry = true
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
    $0.placeholder = "최대 8자"
  }

  private let nickNameViewStack = UIStackView().then {
    $0.axis = .vertical
  }

  private let termsAgreeCheckBox = UIButton(type: .custom).then {
    $0.setImage(UIImage(systemName: "square"), for: .normal)
    $0.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
    $0.tintColor = .main
  }

  private let termsViewButton = UIButton(type: .system).then {
    $0.setTitle("이용 약관", for: .normal)
    $0.setTitleColor(.main, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
  }

  private let termsTextLabel = UILabel().then {
    $0.text = "에 동의합니다."
    $0.font = .systemFont(ofSize: 18, weight: .regular)
  }

  private let termsStackView = UIStackView().then {
    $0.axis = .horizontal
  }

  private let submitButton = UIButton(type: .system).then {
    $0.setTitle("가입하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .main
    $0.layer.cornerRadius = 8

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    setupUI()
    setupConstraints()
    setupButtonActions()
    addTextFieldObservers()
    updateSubmitButtonState()
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
      submitButton,
    ].forEach {
      view.addSubview($0)
    }

    [idLabel, idTextField].forEach {
      idStackView.addArrangedSubview($0)
    }

    [pwLabel, pwTextField].forEach {
      pwStackView.addArrangedSubview($0)
    }

    [rePwLabel, rePwTextField].forEach {
      rePwStackView.addArrangedSubview($0)
    }

    [nickNameLabel, nickNameTextField].forEach {
      nickNameViewStack.addArrangedSubview($0)
    }

    [termsAgreeCheckBox, termsViewButton, termsTextLabel].forEach {
      termsStackView.addArrangedSubview($0)
    }
  }

  // 컴포넌트 레이아웃
  private func setupConstraints() {
    let insetSize = 40
    appLogoImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.trailing.leading.equalToSuperview()
    }

    idStackView.snp.makeConstraints {
      $0.top.equalTo(appLogoImageView.snp.bottom)
      $0.leading.trailing.equalToSuperview().inset(insetSize)
    }

    pwStackView.snp.makeConstraints {
      $0.top.equalTo(idStackView.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(insetSize)
    }

    rePwStackView.snp.makeConstraints {
      $0.top.equalTo(pwStackView.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(insetSize)
    }

    nickNameViewStack.snp.makeConstraints {
      $0.top.equalTo(rePwStackView.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(insetSize)
    }

    termsStackView.setCustomSpacing(4, after: termsAgreeCheckBox)
    termsStackView.snp.makeConstraints {
      $0.top.equalTo(nickNameViewStack.snp.bottom).offset(8)
      $0.centerX.equalToSuperview()
    }

    submitButton.snp.makeConstraints {
      $0.top.equalTo(termsStackView.snp.bottom).offset(8)
      $0.height.equalTo(40)
      $0.leading.trailing.equalToSuperview().inset(insetSize)
      $0.centerX.equalToSuperview()
    }
  }

  // MARK: 버튼 addTarget
  private func setupButtonActions() {
    termsAgreeCheckBox.addTarget(self, action: #selector(didTapCheckbox(_:)), for: .touchUpInside)
    termsViewButton.addTarget(self, action: #selector(didTapTersmView(_:)), for: .touchUpInside)
    submitButton.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
  }
  
  private func addTextFieldObservers() {
    [idTextField, pwTextField, rePwTextField, nickNameTextField].forEach {
      $0.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
  }

  // 가입 버튼 상태 체크
  private func updateSubmitButtonState() {
    let isFiledFilled =
      !(idTextField.text ?? "").isEmpty && !(pwTextField.text ?? "").isEmpty && !(rePwTextField.text ?? "").isEmpty
      && !(nickNameTextField.text ?? "").isEmpty
    let canSubmit = isFiledFilled && isAgreed
    
    submitButton.isEnabled = canSubmit
    submitButton.alpha = canSubmit ? 1.0 : 0.5
  }

  // MARK: 버튼 팡숀
  @objc func didTapCheckbox(_ sender: UIButton) {
    sender.isSelected.toggle()
    isAgreed = sender.isSelected
    updateSubmitButtonState()
    print(sender.isSelected)
  }
  
  @objc func didTapTersmView(_ sender: UIButton) {
    let vc = TermsViewController()
    vc.delegate = self
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    present(nav, animated: true)
  }

  @objc func didTapSubmitButton(_ sender: UIButton) {
    // TODO: 1. coredata에 정보 넣기(이미 있는 아이디인지 확인도 하고 이미 있으면 변경 요청)
    // TODO: 2. 빈 칸(변경 필요한 칸) 파악되면 하이라이팅
    // TODO: 3. userDefault에 넣어서 로그인 창에 정보 미리 넣거나 바로 로그인하게 만들기
    if repository.readUser(by: idTextField.text ?? "ID Data Error") != nil {
      
    }
    navigationController?.popViewController(animated: true)
  }
  
  @objc private func textFieldDidChange(_ sender: UITextField) {
      updateSubmitButtonState()
  } 
}

extension SignViewController: TermsViewControllerDelegate {
  func termsViewControllerDidAgree(_ controller: TermsViewController) {
    termsAgreeCheckBox.isSelected = true
    isAgreed = true
    updateSubmitButtonState()
  }
}
