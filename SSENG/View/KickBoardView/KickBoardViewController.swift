import NMapsMap
import SnapKit
import Then
import UIKit

class KickBoardViewController: UIViewController, UIGestureRecognizerDelegate {
  private let latitude: Double
  private let longitude: Double
  private var selectedType: Int = 1
  private var didRegister: Bool = false // 등록 여부 상태 변수

  // didRegister값 추적을 위한 Delegate 연결
  weak var delegate: KickBoardViewControllerDelegate?

  // MARK: - UI Components

  private let bottomModalView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: -2)
    $0.layer.shadowRadius = 8
  }

  private lazy var modalLabel = UILabel().then {
    $0.text = """
    선택한 위치:
    위도: \(String(format: "%.6f", latitude))
    경도: \(String(format: "%.6f", longitude))
    """
    $0.font = .systemFont(ofSize: 15, weight: .medium)
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }

  private let typeSelectionLabel = UILabel().then {
    $0.text = "킥보드 타입을 선택해주세요."
    $0.font = .systemFont(ofSize: 16, weight: .bold)
    $0.textAlignment = .center
  }

  private lazy var kickboardButton = createTypeButton(title: "킥보드", imageName: "kickboard", tag: 1)
  private lazy var bikeButton = createTypeButton(title: "오토바이", imageName: "bike", tag: 2)

  private lazy var typeSelectionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
    $0.addArrangedSubview(kickboardButton)
    $0.addArrangedSubview(bikeButton)
  }

  private let detailLocationTitleLabel = UILabel().then {
    $0.text = "상세위치:"
    $0.font = .systemFont(ofSize: 16, weight: .bold)
    $0.textAlignment = .center
  }

  private let registerButton = UIButton(type: .system).then {
    $0.setTitle("등록하기", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = UIColor(named: "MainColor")
    $0.tintColor = .white
    $0.layer.cornerRadius = 10
  }

  // MARK: - Properties

  private let repository = KickboardRepository()

  // MARK: - Lifecycle

  init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .overFullScreen
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear

    setupMapView()
    setupModalUI()
    setupActions()
    updateButtonSelection()
    setupDismissTapGesture()

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
          let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

    // 키보드와 텍스트필드 사이 거리 계산
    let bottomSpace = view.frame.height - bottomModalView.frame.origin.y - bottomModalView.frame.height
    let overlap = keyboardFrame.height - bottomSpace

    if overlap > 0 {
      UIView.animate(withDuration: animationDuration) {
        self.bottomModalView.transform = CGAffineTransform(translationX: 0, y: -overlap - 9)
      }
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

    UIView.animate(withDuration: animationDuration) {
      self.bottomModalView.transform = .identity
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if didRegister {
      print("✅ 등록 완료 후 화면이 닫힙니다.")
    } else {
      print("❌ 등록이 취소되었거나, 사용자가 화면을 닫았습니다.")
    }
  }

  // MARK: - UI Setup

  private func setupMapView() {
    let mapView = NMFNaverMapView()
    mapView.showZoomControls = false
    view.addSubview(mapView)
    mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    let marker = NMFMarker()
    marker.position = NMGLatLng(lat: latitude, lng: longitude)
    marker.mapView = mapView.mapView

    let cameraTarget = NMGLatLng(lat: latitude - 0.0004, lng: longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: cameraTarget, zoomTo: 18)
    mapView.mapView.moveCamera(cameraUpdate)
  }

  private let detailLocationTextField = UITextField().then {
    $0.placeholder = "상세 위치를 입력해주세요. (예: 약국 앞)"
    $0.borderStyle = .roundedRect
    $0.font = .systemFont(ofSize: 14)
  }

  private func setupModalUI() {
    view.addSubview(bottomModalView)
    bottomModalView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    for item in [modalLabel, typeSelectionLabel, typeSelectionStackView, detailLocationTitleLabel, detailLocationTextField, registerButton] {
      bottomModalView.addSubview(item)
    }

    modalLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(24)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    typeSelectionLabel.snp.makeConstraints {
      $0.top.equalTo(modalLabel.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    typeSelectionStackView.snp.makeConstraints {
      $0.top.equalTo(typeSelectionLabel.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(40)
      $0.height.equalTo(100)
    }

    detailLocationTitleLabel.snp.makeConstraints {
      $0.top.equalTo(typeSelectionStackView.snp.bottom).offset(30)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    detailLocationTextField.snp.makeConstraints {
      $0.top.equalTo(detailLocationTitleLabel.snp.bottom).offset(8)
      $0.leading.trailing.equalToSuperview().inset(40)
      $0.height.equalTo(44)
    }

    registerButton.snp.makeConstraints {
      $0.top.equalTo(detailLocationTextField.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(200)
      $0.height.equalTo(44)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }

  private func setupActions() {
    registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
  }

  private func setupDismissTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
    tapGesture.delegate = self
    view.addGestureRecognizer(tapGesture)
  }

  // MARK: - Actions

  @objc private func didTapRegister() {
    let detailLocation = detailLocationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    if detailLocation.isEmpty {
      addressShowAlert(title: "입력 오류", message: "상세 위치를 입력해주세요.")
      return
    }

    didRegister = true

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let nowString = dateFormatter.string(from: Date())

    guard let type = selectedType == 1 ? KickboardType.kickboard : selectedType == 2 ? KickboardType.bike : nil else {
      showAlert(title: "타입 오류", message: "유효한 킥보드 타입을 선택해주세요.")
      return
    }

    let registerId = "TEMP_USER_ID"

    let newID = repository.registKickboard(
      registerDate: nowString,
      lat: latitude,
      lng: longitude,
      detailLocation: detailLocation,
      type: type,
      registerId: registerId
    )

    print("✅ 킥보드 등록 완료: ID=\(newID), 위도=\(latitude), 경도=\(longitude), 상세위치=\(detailLocation), 타입=\(selectedType)")

    showAlert(title: "기기 등록", message: "새로운 기기를 등록하겠습니다.") { [weak self] in
      guard let self else { return }
      delegate?.didRegisterKickBoard(at: latitude, longitude: longitude)
      self.navigationController?.popViewController(animated: true)
    }
  }

  @objc private func didTapBackground() {
    view.endEditing(true)
  }

  @objc private func didTapTypeButton(_ sender: UIButton) {
    selectedType = sender.tag
    updateButtonSelection()
  }

  // MARK: - Helpers

  private func createTypeButton(title: String, imageName: String, tag: Int) -> UIButton {
    let button = UIButton(type: .custom)
    button.tag = tag

    var config = UIButton.Configuration.plain()
    config.title = title
    config.imagePlacement = .top
    config.imagePadding = 8
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
      return outgoing
    }

    if let originalImage = UIImage(named: imageName) {
      let newSize = CGSize(width: 50, height: 50)
      let renderer = UIGraphicsImageRenderer(size: newSize)
      let resizedImage = renderer.image { _ in
        originalImage.draw(in: CGRect(origin: .zero, size: newSize))
      }
      config.image = resizedImage
    }

    button.configuration = config
    button.setTitleColor(.black, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.lightGray.cgColor
    button.backgroundColor = .white
    button.addTarget(self, action: #selector(didTapTypeButton), for: .touchUpInside)
    return button
  }

  private func updateButtonSelection() {
    for button in [kickboardButton, bikeButton] {
      let isSelected = (button.tag == selectedType)
      button.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.lightGray.cgColor
      button.layer.borderWidth = isSelected ? 2 : 1
      button.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .white
    }
  }

  private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
      completion?()
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

    present(alert, animated: true)
  }

  private func addressShowAlert(title: String, message: String, completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
      completion?()
    })

    present(alert, animated: true)
  }
}
