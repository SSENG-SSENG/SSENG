import AVFoundation
//
//  ViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import SnapKit
import Then
import UIKit

class LoginViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
  private var isAgreed = false
  private let repository = UserRepository()

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
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.smartInsertDeleteType = .no
    $0.autocapitalizationType = .none
    $0.clearButtonMode = .always
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
    $0.textContentType = .password
    $0.clearButtonMode = .always
    $0.isSecureTextEntry = true
    $0.returnKeyType = .done
    $0.addLeftPadding()
  }

  private let autoLoginAgreeCheckBox = UIButton(type: .custom).then {
    $0.setImage(UIImage(systemName: "square"), for: .normal)
    $0.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
    $0.tintColor = .main
  }

  private let autoLoginAgreeLabel = UILabel().then {
    $0.text = "자동 로그인"
    $0.font = .systemFont(ofSize: 18, weight: .medium)
  }

  private let autoLoginStackView = UIStackView().then {
    $0.axis = .horizontal
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

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateContentAppearance()
    updateLoginButtonState()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.delegate = self
    view.backgroundColor = .systemBackground

    setupUI()
    setupConstraints()
    setupButtonActions()
    addTextFieldObsevers()
    updateLoginButtonState()
    dismissKeyboardController()

    [idTextField, pwTextField].forEach { $0.delegate = self }

    prepareForTransition()
  }

  func setupUI() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    contentView.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(appLogoImageView)
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    scrollView.showsVerticalScrollIndicator = false

    for item in [idStackView, pwStackView, autoLoginStackView, loginButton, signUpBUtton] {
      contentView.addSubview(item)
    }

    for item in [idLabel, idTextField] {
      idStackView.addArrangedSubview(item)
    }

    for item in [pwLabel, pwTextField] {
      pwStackView.addArrangedSubview(item)
    }

    for item in [autoLoginAgreeCheckBox, autoLoginAgreeLabel] {
      autoLoginStackView.addArrangedSubview(item)
    }
  }

  // 컴포넌트 레이아웃
  func setupConstraints() {
    let padding: CGFloat = 60
    let height: CGFloat = 48

    appLogoImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(100)
    }

    scrollView.snp.makeConstraints {
      $0.top.equalTo(appLogoImageView.snp.bottom).offset(10)
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

    autoLoginStackView.setCustomSpacing(4, after: autoLoginAgreeCheckBox)
    autoLoginStackView.snp.makeConstraints {
      $0.top.equalTo(pwStackView.snp.bottom).offset(10)
      $0.centerX.equalToSuperview()
    }

    loginButton.snp.makeConstraints {
      $0.top.equalTo(autoLoginStackView.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.height.equalTo(height)
      $0.centerX.equalToSuperview()
    }

    signUpBUtton.snp.makeConstraints {
      $0.top.equalTo(loginButton.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(padding)
      $0.height.equalTo(height)
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().inset(24)
    }
  }

  // MARK: 버튼 addTarget

  private func setupButtonActions() {
    loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    signUpBUtton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    autoLoginAgreeCheckBox.addTarget(self, action: #selector(didTapAutoLoginAgree), for: .touchUpInside)
  }

  // 텍스트 입력 때 길이 등 필터링
  private func addTextFieldObsevers() {
    for item in [idTextField, pwTextField] {
      item.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
  }

  // userDefault 생성
  func createDefaultUser(id: String) {
    // 자동 로그인
    if isAgreed {
      UserDefaults.standard.set(true, forKey: "isAutoLogin")
    } else {
      UserDefaults.standard.set(false, forKey: "isAutoLogin")
    }
    //  로그인 유저 데이터
    UserDefaults.standard.set(id, forKey: "loggedUserID")
  }

  // 텍스트 필드 상태에 따라 버튼 활성화
  private func updateLoginButtonState() {
    let id = idTextField.text ?? ""
    let pw = pwTextField.text ?? ""
    let allVAlid = isValidID(id) && isValidPW(pw)

    loginButton.isEnabled = allVAlid
    loginButton.alpha = allVAlid ? 1.0 : 0.5
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
    case pwTextField:
      return updated.count <= 32
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
      pwTextField.resignFirstResponder()
    default:
      break
    }
    return false
  }

  // 화면 전환 때 로고 애니메이션
  func navigationController(
    _: UINavigationController,
    animationControllerFor operation: UINavigationController.Operation,
    from fromVC: UIViewController,
    to toVC: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    if fromVC is LoginViewController && toVC is SignViewController
      || fromVC is SignViewController && toVC is LoginViewController
    {
      return LogoTransitionAnimator(operation: operation)
    }
    return nil
  }

  // 화면 전환될 때 투명도 조절
  func prepareForTransition() {
    for item in [idStackView, pwStackView, autoLoginStackView, loginButton, signUpBUtton] {
      item.alpha = 0
    }
  }

  // 화면 전환될 때 컴포넌트가 아래에서 위로 애니메이션
  func animateContentAppearance() {
    let components: [UIView] = [
      idStackView,
      pwStackView,
      autoLoginStackView,
      loginButton,
      signUpBUtton,
    ]
    let baseDelay: TimeInterval = 0.05
    let animationDuration: TimeInterval = 0.25
    let initialTranslationY: CGFloat = 20  // 아래쪽에서 20pt 만큼 시작

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

  // MARK: 버튼 기능들
  // 체크박스
  @objc func didTapAutoLoginAgree(_ sender: UIButton) {
    sender.isSelected.toggle()
    isAgreed = sender.isSelected
  }

  // 로그인 버튼 누르면: 존재, 필터링 체크
  @objc func didTapLogin() {
    if repository.readUser(by: idTextField.text ?? "id-xxxx")?.id != idTextField.text {
      idTextField.becomeFirstResponder()
      alertController(on: self, title: "아이디 오류", message: "해당 아이디가 존재하지 않습니다.")
    }

    if repository.readUser(by: idTextField.text ?? "pw-xxxx")?.password != pwTextField.text {
      pwTextField.becomeFirstResponder()
      alertController(on: self, title: "비밀번호 오류", message: "비밀번호가 일치하지 않습니다.")
    }

    createDefaultUser(id: idTextField.text ?? "no id")
    let mapVC = MapViewController()
    navigationController?.pushViewController(mapVC, animated: true)
  }

  // 회원가입 클릭하면: 회원가입 VC로 이동
  @objc func didTapSignUp() {
    let signUpVC = SignViewController()
    signUpVC.prepareForTransition()
    navigationController?.pushViewController(signUpVC, animated: true)
  }



  // 텍스트가 입력될 때마다 필터링
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
  
  // 화면 터치 인식되면 키보드 내려감
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
