import NMapsMap
import SnapKit
import Then
import UIKit

// 킥보드 등록을 담당하는 뷰 컨트롤러
class KickBoardViewController: UIViewController, UIGestureRecognizerDelegate {
  // MARK: - Properties

  private let latitude: Double // 지도에서 전달받은 위도
  private let longitude: Double // 지도에서 전달받은 경도
  private var selectedType: Int = 1 // 선택된 기기 타입 (1: 킥보드, 2: 오토바이)
  private var didRegister: Bool = false // 등록 완료 여부 상태 변수

  // MapViewController에 등록 완료를 알리기 위한 Delegate
  weak var delegate: KickBoardViewControllerDelegate?

  // CoreData와 상호작용하기 위한 Repository
  private let repository = KickboardRepository()

  // MARK: - UI Components

  // 하단에 올라오는 모달 뷰
  private let bottomModalView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: -2)
    $0.layer.shadowRadius = 8
  }

  // 위도, 경도 표시 레이블
  private lazy var modalLabel = UILabel().then {
    $0.text = """
    위도: \(String(format: "%.6f", latitude)) 경도: \(String(format: "%.6f", longitude))
    """
    $0.font = .systemFont(ofSize: 15, weight: .medium)
    $0.textAlignment = .center
    $0.numberOfLines = 0
  }

  // 타입 선택 안내 레이블
  private let typeSelectionLabel = UILabel().then {
    $0.text = "킥보드 타입을 선택해 주세요."
    $0.font = .systemFont(ofSize: 16, weight: .bold)
    $0.textAlignment = .center
  }

  // 킥보드/오토바이 선택 버튼
  private lazy var kickboardButton = createTypeButton(title: "킥보드", imageName: "kickboard", tag: 1)
  private lazy var bikeButton = createTypeButton(title: "오토바이", imageName: "bike", tag: 2)

  // 타입 선택 버튼을 묶는 스택 뷰
  private lazy var typeSelectionStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 16
    $0.distribution = .fillEqually
    $0.addArrangedSubview(kickboardButton)
    $0.addArrangedSubview(bikeButton)
  }

  // 상세 위치 입력 안내 레이블
  private let detailLocationTitleLabel = UILabel().then {
    $0.text = "상세 위치:"
    $0.font = .systemFont(ofSize: 16, weight: .bold)
    $0.textAlignment = .center
  }

  // 상세 위치 입력 텍스트 필드
  private let detailLocationTextField = UITextField().then {
    $0.placeholder = "상세 위치를 입력해 주세요. (예: 약국 앞)"
    $0.borderStyle = .roundedRect
    $0.font = .systemFont(ofSize: 14)
  }

  // 등록하기 버튼
  private let registerButton = UIButton(type: .system).then {
    $0.setTitle("등록하기", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = UIColor(named: "MainColor")
    $0.tintColor = .white
    $0.layer.cornerRadius = 10
  }

  // MARK: - Lifecycle

  // 초기화 메서드
  init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .overFullScreen // 전체 화면으로 표시
  }

  // 필수 초기화 메서드 (사용 안 함)
  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // 뷰가 로드되었을 때 호출
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear // 배경을 투명하게 설정

    setupMapView() // 지도 설정
    setupModalUI() // 모달 UI 설정
    setupActions() // 버튼 액션 설정
    updateButtonSelection() // 초기 버튼 선택 상태 업데이트
    setupDismissTapGesture() // 배경 탭 제스처 설정

    // 키보드 나타남/사라짐을 감지하는 옵저버 등록
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  // 뷰가 사라지기 직전에 호출
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true) // 화면을 벗어날 때 키보드를 항상 내림
    if didRegister {
      print("✅ 등록 완료 후 화면이 닫힙니다.")
    } else {
      print("❌ 등록이 취소되었거나, 사용자가 화면을 닫았습니다.")
    }
  }

  // 소멸자: 옵저버 제거
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Keyboard Handling

  // 키보드가 나타날 때 호출되는 메서드
  @objc private func keyboardWillShow(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
          let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

    // '등록하기' 버튼의 화면 내 위치 계산
    let buttonFrameInView = view.convert(registerButton.frame, from: registerButton.superview)
    let buttonBottomY = buttonFrameInView.maxY

    // 키보드의 상단 Y 좌표
    let keyboardTopY = view.frame.height - keyboardFrame.height

    // 버튼이 키보드에 의해 얼마나 가려지는지 계산
    let overlap = buttonBottomY - keyboardTopY

    // 가려지는 부분이 있다면 모달 뷰를 위로 올림
    if overlap > 0 {
      UIView.animate(withDuration: animationDuration) {
        self.bottomModalView.transform = CGAffineTransform(translationX: 0, y: -overlap - 10)
      }
    }
  }

  // 키보드가 사라질 때 호출되는 메서드
  @objc private func keyboardWillHide(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

    // 모달 뷰를 원래 위치로 되돌림
    UIView.animate(withDuration: animationDuration) {
      self.bottomModalView.transform = .identity
    }
  }

  // MARK: - UI Setup

  // 배경 지도 뷰 설정
  private func setupMapView() {
    let mapView = NMFNaverMapView()
    mapView.showZoomControls = false
    view.addSubview(mapView)
    mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    // 선택된 위치에 마커 표시
    let marker = NMFMarker()
    marker.position = NMGLatLng(lat: latitude, lng: longitude)
    marker.mapView = mapView.mapView

    // 카메라 위치 조정
    let cameraTarget = NMGLatLng(lat: latitude - 0.0004, lng: longitude)
    let cameraUpdate = NMFCameraUpdate(scrollTo: cameraTarget, zoomTo: 18)
    mapView.mapView.moveCamera(cameraUpdate)
  }

  // 하단 모달 UI 레이아웃 설정
  private func setupModalUI() {
    view.addSubview(bottomModalView)
    bottomModalView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    // 모달 뷰에 UI 컴포넌트 추가
    for item in [modalLabel, typeSelectionLabel, typeSelectionStackView, detailLocationTitleLabel, detailLocationTextField, registerButton] {
      bottomModalView.addSubview(item)
    }

    // SnapKit을 이용한 오토레이아웃 설정
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

  // MARK: - Actions

  // 버튼 액션 연결
  private func setupActions() {
    registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
  }

  // 배경 탭 시 키보드 내리는 제스처 설정
  private func setupDismissTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackground))
    tapGesture.delegate = self
    view.addGestureRecognizer(tapGesture)
  }

  // '등록하기' 버튼 탭 액션
  @objc private func didTapRegister() {
    view.endEditing(true) // 버튼 클릭 시 키보드를 내림
    let detailLocation = detailLocationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    // 상세 위치 입력 유효성 검사
    if detailLocation.isEmpty {
      addressShowAlert(title: "입력 오류", message: "상세 위치를 입력해 주세요.")
      return
    }

    // 로그인 상태 확인
    guard let registerId = UserDefaults.standard.string(forKey: "loggedUserID"), !registerId.isEmpty else {
      addressShowAlert(title: "로그인 필요", message: "킥보드를 등록하려면 로그인이 필요합니다.")
      return
    }

    // 사용자에게 먼저 등록 여부를 물어봅니다.
    showAlert(title: "기기 등록", message: "새로운 기기를 등록할까요?") { [weak self] in
      // '확인'을 눌렀을 때만 아래 로직이 실행됩니다.
      guard let self else { return }

      self.didRegister = true // 등록 상태를 true로 변경

      // 현재 날짜를 문자열로 변환
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
      let nowString = dateFormatter.string(from: Date())

      // 선택된 타입 확인
      guard let type = self.selectedType == 1 ? KickboardType.kickboard : self.selectedType == 2 ? KickboardType.bike : nil else {
        self.showAlert(title: "타입 오류", message: "유효한 킥보드 타입을 선택해 주세요.")
        return
      }

      // CoreData에 킥보드 정보 등록
      let newID = self.repository.registKickboard(
        registerDate: nowString,
        lat: self.latitude,
        lng: self.longitude,
        detailLocation: detailLocation,
        type: type,
        registerId: registerId
      )

      print("✅ 킥보드 등록 완료: ID=\(newID), 위도=\(self.latitude), 경도=\(self.longitude), 상세 위치=\(detailLocation), 타입=\(self.selectedType), 등록자 ID=\(registerId)")

      // 델리게이트를 통해 MapView에 알리고, 화면을 닫습니다.
      self.delegate?.didRegisterKickBoard(at: self.latitude, longitude: self.longitude)
      self.navigationController?.popViewController(animated: true)
    }
  }

  // 배경 탭 액션
  @objc private func didTapBackground() {
    view.endEditing(true) // 키보드를 내림
  }

  // 타입 선택 버튼 탭 액션
  @objc private func didTapTypeButton(_ sender: UIButton) {
    selectedType = sender.tag
    updateButtonSelection() // 버튼 UI 업데이트
  }

  // MARK: - Helpers

  // 타입 선택 버튼 생성 헬퍼 메서드
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

    // 이미지 리사이징
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

  // 선택된 타입에 따라 버튼 UI를 업데이트하는 메서드
  private func updateButtonSelection() {
    for button in [kickboardButton, bikeButton] {
      let isSelected = (button.tag == selectedType)
      button.layer.borderColor = isSelected ? UIColor.systemBlue.cgColor : UIColor.lightGray.cgColor
      button.layer.borderWidth = isSelected ? 2 : 1
      button.backgroundColor = isSelected ? UIColor.systemBlue.withAlphaComponent(0.1) : .white
    }
  }

  // 확인/취소 알림창 표시 헬퍼 메서드
  private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
      completion?()
    })
    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

    present(alert, animated: true)
  }

  // 확인 알림창 표시 헬퍼 메서드 (입력 오류 등)
  private func addressShowAlert(title: String, message: String, completion: (() -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
      self?.view.endEditing(true)
      completion?()
    })

    present(alert, animated: true)
  }
}
