//
//  SignViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import AVFoundation
import SnapKit
import Then
import UIKit

class SignViewController: UIViewController, UITextFieldDelegate {
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

  let appLogoImageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }

  private let scrollView = UIScrollView()
  private let contentView = UIView()

  private let idLabel = UILabel().then {
    $0.text = "아이디"
    $0.font = .systemFont(ofSize: 15, weight: .medium)
  }

  private let idTextField = UITextField().then {
    $0.placeholder = "영어/숫자 4-16자"
    $0.keyboardType = .asciiCapable
    $0.textContentType = .none
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.smartInsertDeleteType = .no
    $0.clearButtonMode = .whileEditing
    $0.returnKeyType = .next
    $0.addLeftPadding()
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
    $0.placeholder = "영어/숫자/기호 8-32자"
    $0.clearButtonMode = .whileEditing
    $0.isSecureTextEntry = true
    $0.returnKeyType = .next
    $0.addLeftPadding()
  }

  private let pwStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6
  }

  private let rePwLabel = UILabel().then {
    $0.text = "비밀번호 재확인"
    $0.font = .systemFont(ofSize: 15, weight: .medium)
  }

  private let rePwTextField = UITextField().then {
    $0.placeholder = "비밀번호를 다시 입력하세요."
    $0.clearButtonMode = .whileEditing
    $0.isSecureTextEntry = true
    $0.returnKeyType = .next
    $0.addLeftPadding()
  }

  private let rePwStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6
  }

  private let nameLabel = UILabel().then {
    $0.text = "닉네임"
    $0.font = .systemFont(ofSize: 15, weight: .medium)
  }

  private let nameTextField = UITextField().then {
    $0.placeholder = "한글/영어 1-8자"
    $0.clearButtonMode = .whileEditing
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.smartInsertDeleteType = .no
    $0.returnKeyType = .done
    $0.addLeftPadding()
  }

  private let nameStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 6
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

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isMovingFromParent {
      if let loginVC = navigationController?.viewControllers.last(where: { $0 is LoginViewController })
        as? LoginViewController
      {
        loginVC.prepareForTransition()
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    setupUI()
    setupConstraints()
    setupButtonActions()
    addTextFieldObservers()
    updateSubmitButtonState()
    dismissKeyboardController()

    [idTextField, pwTextField, rePwTextField, nameTextField].forEach { $0.delegate = self }

    prepareForTransition()
  }

  // 뷰, 스택
  private func setupUI() {
    [
      appLogoImageView,
      scrollView,
      idStackView,
      pwStackView,
      rePwStackView,
      nameStackView,
      termsStackView,
      submitButton
    ].forEach {
      view.addSubview($0)
    }

    scrollView.addSubview(contentView)

    for item in [idStackView, pwStackView, rePwStackView, nameStackView, termsStackView, submitButton] {
      contentView.addSubview(item)
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

    for item in [nameLabel, nameTextField] {
      nameStackView.addArrangedSubview(item)
    }

    for item in [termsAgreeCheckBox, termsViewButton, termsTextLabel] {
      termsStackView.addArrangedSubview(item)
    }
  }

  // 컴포넌트 레이아웃
  private func setupConstraints() {
    let padding: CGFloat = 60
    let height: CGFloat = 48

    appLogoImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
      $0.centerX.equalToSuperview()
      $0.trailing.leading.equalToSuperview()
      $0.width.equalTo(30)
      $0.height.equalTo(80)
    }

    scrollView.snp.makeConstraints {
      $0.top.equalTo(appLogoImageView.snp.bottom).offset(30)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
    }

    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalTo(scrollView.snp.width)
    }

    idTextField.snp.makeConstraints {
      $0.height.equalTo(height)
    }

    idStackView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(30)
      $0.leading.trailing.equalToSuperview().inset(padding)
      // $0.centerX.equalToSuperview()
    }

    pwTextField.snp.makeConstraints {
      $0.height.equalTo(height)
    }

    pwStackView.snp.makeConstraints {
      $0.top.equalTo(idStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(padding)
      // $0.centerX.equalToSuperview()
    }

    rePwTextField.snp.makeConstraints {
      $0.height.equalTo(height)
    }

    rePwStackView.snp.makeConstraints {
      $0.top.equalTo(pwStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(padding)
      // $0.centerX.equalToSuperview()
    }

    nameTextField.snp.makeConstraints {
      $0.height.equalTo(height)
    }

    nameStackView.snp.makeConstraints {
      $0.top.equalTo(rePwStackView.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview().inset(padding)
      // $0.centerX.equalToSuperview()
    }

    termsStackView.setCustomSpacing(4, after: termsAgreeCheckBox)
    termsStackView.snp.makeConstraints {
      $0.top.equalTo(nameStackView.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
    }

    submitButton.snp.makeConstraints {
      $0.top.equalTo(termsStackView.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.height.equalTo(height)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(24)
    }
  }

  // MARK: 버튼 addTarget

  private func setupButtonActions() {
    termsAgreeCheckBox.addTarget(self, action: #selector(didTapCheckbox(_:)), for: .touchUpInside)
    termsViewButton.addTarget(self, action: #selector(didTapTersmView(_:)), for: .touchUpInside)
    submitButton.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
  }

  // 텍스트 입력 때 길이 등 필터링
  private func addTextFieldObservers() {
    for item in [idTextField, pwTextField, rePwTextField, nameTextField] {
      item.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
  }

  // 텍스트 필드 상태에 따라 버튼 활성화
  private func updateSubmitButtonState() {
    let id = idTextField.text ?? ""
    let pw = pwTextField.text ?? ""
    let rePw = rePwTextField.text ?? ""
    let name = nameTextField.text ?? ""
    let allValid =
      isValidID(id)
        && isValidPW(pw)
        && !rePw.isEmpty
        && isValidName(name)
        && isAgreed

    submitButton.isEnabled = allValid
    submitButton.alpha = allValid ? 1.0 : 0.5
  }

  // 정규표현식 및 글자수 제한
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
    -> Bool
  {
    guard let t = textField.text as NSString? else { return true }
    let updated = t.replacingCharacters(in: range, with: string)
    switch textField {
    case idTextField:
      return updated.count <= 16
        && (string.isEmpty || string.range(of: "[^a-z0-9]", options: .regularExpression) == nil)
    case pwTextField, rePwTextField:
      return updated.count <= 32
    case nameTextField:
      return updated.replacingOccurrences(of: " ", with: "").count <= 8
    default:
      return true
    }
  }

  // 각 칸 정규식
  private func isValidID(_ id: String) -> Bool {
    id.range(of: #"^[a-z0-9]{4,16}$"#, options: .regularExpression) != nil
  }

  private func isValidPW(_ pw: String) -> Bool {
    pw.range(of: #"^[A-Za-z\d!@#$&*]{8,32}$"#, options: .regularExpression) != nil
  }

  private func isValidName(_ nick: String) -> Bool {
    let trimmed = nick.replacingOccurrences(of: " ", with: "")
    return trimmed.range(of: #"^[가-힣A-Za-z0-9]{1,8}$"#, options: .regularExpression) != nil
  }

  // alert 컨트롤러
  func alertController(on vc: UIViewController, title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    vc.present(alert, animated: true)
  }

  // 터치 제스처 인식
  func dismissKeyboardController() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }

  // 텍스트 필드 누르면 테두리 표시
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.borderStyle = .roundedRect
    textField.layer.borderColor = UIColor.main.cgColor
    textField.layer.cornerRadius = 3.0
    textField.layer.borderWidth = 1.0
  }

  // 텍스트 필드 누르면 테두리 해제
  func textFieldDidEndEditing(_ textField: UITextField) {
    textField.borderStyle = .none
    textField.backgroundColor = .clear
    textField.layer.borderColor = UIColor.clear.cgColor
  }

  // 키보드 리턴 누를 때
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // 필드가 비어있다면 필드가 흔들리고 진동이 울림
    guard let text = textField.text, !text.isEmpty else {
      textField.shake()
      AudioServicesPlaySystemSound(4095)
      return false
    }
    // 텍스트 필드 위치에 따라 아래로 내려가거나 키보드가 닫힘
    switch textField {
    case idTextField:
      pwTextField.becomeFirstResponder()
    case pwTextField:
      rePwTextField.becomeFirstResponder()
    case rePwTextField:
      nameTextField.becomeFirstResponder()
    case nameTextField:
      nameTextField.resignFirstResponder()
    default:
      break
    }
    return false
  }

  // 화면 전환될 때 투명도 조절
  func prepareForTransition() {
    for item in [idStackView, pwStackView, rePwStackView, nameStackView, termsStackView, submitButton] {
      item.alpha = 0
    }
  }

  // 화면 전환될 때 컴포넌트가 아래에서 위로 애니메이션
  func animateContentAppearance() {
    let components: [UIView] = [
      idStackView,
      pwStackView,
      rePwStackView,
      nameStackView,
      termsStackView,
      submitButton
    ]
    let baseDelay: TimeInterval = 0.05
    let animationDuration: TimeInterval = 0.25
    let initialTranslationY: CGFloat = 20 // 아래쪽에서 20pt 만큼 시작

    for (index, component) in components.enumerated() {
      component.alpha = 0
      component.transform = CGAffineTransform(translationX: 0, y: initialTranslationY)

      UIView.animate(
        withDuration: animationDuration,
        delay: baseDelay * Double(index),
        options: [.curveEaseOut],
        animations: {
          component.alpha = 1
          component.transform = .identity
        },
        completion: nil
      )
    }
  }

  // MARK: 버튼 팡숀
  // 체크박스
  @objc func didTapCheckbox(_ sender: UIButton) {
    sender.isSelected.toggle()
    isAgreed = sender.isSelected
    updateSubmitButtonState()
  }
  
  // 가입 버튼 누르면: 중복, 필터링 체크
  @objc func didTapSubmitButton(_: UIButton) {
    // TODO: 3. userDefault에 넣어서 로그인 창에 정보 미리 넣거나 바로 로그인하게 만들기
    let id = idTextField.text ?? ""
    let pw = pwTextField.text ?? ""
    let rePw = rePwTextField.text ?? ""
    let name = nameTextField.text ?? ""

    // 입력 잘못된 칸 Alert
    if !isValidID(id) {
      idTextField.becomeFirstResponder()
      alertController(on: self, title: "아이디 오류", message: "아이디는 4-16자 영문 소문자와 숫자로만 구성되어야 합니다.")
      return
    }

    if repository.readUser(by: idTextField.text ?? "id-xxxx") != nil {
      idTextField.becomeFirstResponder()
      alertController(on: self, title: "아이디 중복", message: "중복된 아이디입니다.\n다른 아이디를 사용해 주세요.")
      return
    }

    if !isValidPW(pw) {
      pwTextField.becomeFirstResponder()
      alertController(on: self, title: "패스워드 오류", message: "비밀번호는 8-32자 영문 대소문자, 숫자, 특수문자를 포함해야 합니다.")
      return
    }

    if pw != rePw {
      pwTextField.becomeFirstResponder()
      alertController(on: self, title: "패스워드 재확인 오류", message: "패스워드가 같지 않습니다.")
      return
    }

    if !isValidName(name) {
      nameTextField.becomeFirstResponder()
      alertController(on: self, title: "닉네임 오류", message: "잘못된 닉네임입니다.")
      return
    }

    if repository.readName(by: nameTextField.text ?? "name-xxxx") != nil {
      nameTextField.becomeFirstResponder()
      alertController(on: self, title: "닉네임 중복", message: "중복된 닉네임입니다.\n다른 아이디를 사용해 주세요.")

      return
    }

    repository.createUser(id: idTextField.text!, name: nameTextField.text!, password: pwTextField.text!)
    if let loginVC = navigationController?.viewControllers.last(where: { $0 is LoginViewController })
      as? LoginViewController
    {
      loginVC.prepareForTransition()
    }
    navigationController?.popViewController(animated: true)
  }

  // 이용약관 클릭하면: 약관 VC로 이동
  @objc func didTapTersmView(_: UIButton) {
    let vc = TermsViewController()
    vc.delegate = self
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet
    present(nav, animated: true)
  }

  // 텍스트가 입력될 때마다 필터링
  @objc private func textFieldDidChange(_ textField: UITextField) {
    switch textField {
    case idTextField:
      if let text = textField.text {
        let filtered = text.lowercased().filter { $0.isLetter || $0.isNumber }
        textField.text = String(filtered.prefix(16))
      }

    case pwTextField, rePwTextField:
      if let text = textField.text, text.count > 32 {
        textField.text = String(text.prefix(32))
      }

    case nameTextField:
      if let text = textField.text {
        let trimmed = text.replacingOccurrences(of: " ", with: "")
        let allowed = trimmed.filter { isKorean($0) || $0.isLetter || $0.isNumber }
        textField.text = String(allowed.prefix(8))
      }

    default:
      break
    }
    updateSubmitButtonState()
  }

  // 화면 터치 인식되면 키보드 내려감
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }

  // 이름이 한국어일 때 완성된 글자인지 체크
  private func isKorean(_ character: Character) -> Bool {
    guard let scalar = character.unicodeScalars.first else { return false }
    return scalar.value >= 0xAC00 && scalar.value <= 0xD7A3
  }
}

// TermsViewController 데이터 가져오기
// 거부, 승낙마다 체크박스 상태 변화
extension SignViewController: TermsViewControllerDelegate {
  func termsViewControllerDidAgree(_: TermsViewController) {
    termsAgreeCheckBox.isSelected = true
    isAgreed = true
    updateSubmitButtonState()
  }

  func termsViewControllerDidReject(_: TermsViewController) {
    termsAgreeCheckBox.isSelected = false
    isAgreed = false
    updateSubmitButtonState()
  }
}

// 텍스트 필드 흔드는 기능
extension UIView {
  func shake(duration: CFTimeInterval = 0.5, repeatCount: Float = 2) {
    let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
    animation.timingFunction = CAMediaTimingFunction(name: .linear)
    animation.duration = duration
    animation.values = [-8, 8, -6, 6, -4, 4, -2, 2, 0]
    animation.repeatCount = repeatCount
    layer.add(animation, forKey: "shake")
  }
}

// 텍스트 필드 좌측 간격
extension UITextField {
  func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: frame.height))
    leftView = paddingView
    leftViewMode = .always
  }
}
