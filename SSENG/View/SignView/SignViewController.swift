import AVFoundation
import SnapKit
import Then
import UIKit

enum SignUpSection: Int, CaseIterable {
  case id, pw, rePw, name

  var cellIdentifier: String {
    switch self {
    case .id: return "IDCell"
    case .pw: return "PWCell"
    case .rePw: return "RePWCell"
    case .name: return "NameCell"
    }
  }
}

class SignViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
  private var id = ""
  private var pw = ""
  private var rePw = ""
  private var name = ""
  private var isAgreed = false
  private let repository = UserRepository()

  let appLogoImageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 18
    layout.scrollDirection = .vertical
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .clear
    cv.keyboardDismissMode = .onDrag
    for section in SignUpSection.allCases {
      cv.register(SignTextFieldCell.self, forCellWithReuseIdentifier: section.cellIdentifier)
    }
    return cv
  }()

  private let termsAgreeCheckBox = UIButton(type: .custom).then {
    $0.setImage(UIImage(systemName: "square"), for: .normal)
    $0.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
    $0.tintColor = .systemBlue
  }

  private let termsViewButton = UIButton(type: .system).then {
    $0.setTitle("이용 약관", for: .normal)
    $0.setTitleColor(.systemBlue, for: .normal)
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
  }

  private let termsTextLabel = UILabel().then {
    $0.text = "에 동의합니다."
    $0.font = .systemFont(ofSize: 18, weight: .regular)
  }

  private let termsStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 4
    $0.alignment = .center
  }

  private let submitButton = UIButton(type: .system).then {
    $0.setTitle("가입하기", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .systemBlue
    $0.layer.cornerRadius = 8
    $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    setupUI()
    setupConstraints()
    addActions()
    dismissKeyboardController()

    // 애니메이션을 위한 alpha 0으로 초기화
    prepareForTransition()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animateContentAppearance()
  }

  private func setupUI() {
    view.addSubview(appLogoImageView)
    view.addSubview(collectionView)
    view.addSubview(termsStackView)
    view.addSubview(submitButton)
    for item in [termsAgreeCheckBox, termsViewButton, termsTextLabel] {
      termsStackView.addArrangedSubview(item)
    }
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  private func setupConstraints() {
    appLogoImageView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(80)
    }
    collectionView.snp.makeConstraints {
      $0.top.equalTo(appLogoImageView.snp.bottom).offset(30)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(320)
    }
    termsStackView.snp.makeConstraints {
      $0.top.equalTo(collectionView.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
    }
    submitButton.snp.makeConstraints {
      $0.top.equalTo(termsStackView.snp.bottom).offset(24)
      $0.leading.trailing.equalToSuperview().inset(40)
      $0.height.equalTo(48)
    }
  }

  private func addActions() {
    termsAgreeCheckBox.addTarget(self, action: #selector(didTapCheckbox(_:)), for: .touchUpInside)
    termsViewButton.addTarget(self, action: #selector(didTapTermsView(_:)), for: .touchUpInside)
    submitButton.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
  }

  // MARK: - CollectionView DataSource

  func numberOfSections(in _: UICollectionView) -> Int { 1 }
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    SignUpSection.allCases.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let section = SignUpSection(rawValue: indexPath.item)!
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.cellIdentifier, for: indexPath) as! SignTextFieldCell

    switch section {
    case .id:
      cell.configure(title: "아이디", placeholder: "영어/숫자 4-16자", value: id, isSecure: false)
      cell.textField.delegate = self
      cell.textField.tag = 1
    case .pw:
      cell.configure(title: "비밀번호", placeholder: "영어/숫자/기호 8-32자", value: pw, isSecure: true)
      cell.textField.delegate = self
      cell.textField.tag = 2
    case .rePw:
      cell.configure(title: "비밀번호 재확인", placeholder: "비밀번호를 다시 입력하세요.", value: rePw, isSecure: true)
      cell.textField.delegate = self
      cell.textField.tag = 3
    case .name:
      cell.configure(title: "닉네임", placeholder: "한글/영어 1-8자", value: name, isSecure: false)
      cell.textField.delegate = self
      cell.textField.tag = 4
    }
    cell.textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    return cell
  }

  // MARK: - CollectionView DelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
    let width = collectionView.bounds.width - 40
    return CGSize(width: width, height: 72)
  }

  // MARK: - 텍스트필드 입력제한/유효성

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard let t = textField.text as NSString? else { return true }
    let updated = t.replacingCharacters(in: range, with: string)
    switch textField.tag {
    case 1: // id
      return updated.count <= 16 && (string.isEmpty || string.range(of: "[^a-z0-9]", options: .regularExpression) == nil)
    case 2, 3: // pw, repw
      return updated.count <= 32
    case 4: // name
      return updated.replacingOccurrences(of: " ", with: "").count <= 8
    default:
      return true
    }
  }

  @objc private func textFieldDidChange(_ textField: UITextField) {
    switch textField.tag {
    case 1: id = textField.text ?? ""
    case 2: pw = textField.text ?? ""
    case 3: rePw = textField.text ?? ""
    case 4: name = textField.text ?? ""
    default: break
    }
    updateSubmitButtonState()
  }

  private func updateSubmitButtonState() {
    let allValid = isValidID(id) && isValidPW(pw) && !rePw.isEmpty && pw == rePw && isValidName(name) && isAgreed
    submitButton.isEnabled = allValid
    submitButton.alpha = allValid ? 1.0 : 0.5
  }

  // MARK: - 버튼, 체크박스, 약관

  @objc private func didTapCheckbox(_ sender: UIButton) {
    sender.isSelected.toggle()
    isAgreed = sender.isSelected
    updateSubmitButtonState()
  }

  @objc private func didTapTermsView(_: UIButton) {
    // 약관 보기 화면 호출 (필요시 구현)
  }

  @objc private func didTapSubmitButton(_: UIButton) {
    // 가입 처리 로직 구현 (필요시 검증 및 alert 등)
    print("가입 시도: \(id), \(pw), \(rePw), \(name), 동의:\(isAgreed)")
  }

  func dismissKeyboardController() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }

  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }

  // MARK: - 애니메이션

  func prepareForTransition() {
    [collectionView, termsStackView, submitButton].forEach { $0.alpha = 0 }
  }

  func animateContentAppearance() {
    let components: [UIView] = [collectionView, termsStackView, submitButton]
    let baseDelay: TimeInterval = 0.07
    let animationDuration: TimeInterval = 0.25
    let initialTranslationY: CGFloat = 20

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

  // 유효성 검증 함수
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
}

// MARK: - 커스텀 셀 (원래 스타일)

class SignTextFieldCell: UICollectionViewCell {
  let titleLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 15, weight: .medium)
  }

  let textField = UITextField().then {
    $0.clearButtonMode = .whileEditing
    $0.autocapitalizationType = .none
    $0.autocorrectionType = .no
    $0.spellCheckingType = .no
    $0.smartInsertDeleteType = .no
    $0.returnKeyType = .done
    $0.borderStyle = .roundedRect
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(titleLabel)
    contentView.addSubview(textField)
    titleLabel.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(4)
    }
    textField.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(6)
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(44)
    }
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) { fatalError() }

  func configure(title: String, placeholder: String, value: String, isSecure: Bool = false) {
    titleLabel.text = title
    textField.placeholder = placeholder
    textField.text = value
    textField.isSecureTextEntry = isSecure
  }
}

// 확장
extension UITextField {
  func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: frame.height))
    leftView = paddingView
    leftViewMode = .always
  }
}

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
