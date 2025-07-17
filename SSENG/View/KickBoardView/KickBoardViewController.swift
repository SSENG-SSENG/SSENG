import NMapsMap
import SnapKit
import Then
import UIKit

class KickBoardViewController: UIViewController {
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

  private let closeButton = UIButton(type: .system).then {
    $0.setImage(UIImage(systemName: "xmark"), for: .normal)
    $0.tintColor = .darkGray
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

  private let registerButton = UIButton(type: .system).then {
    $0.setTitle("등록하기", for: .normal)
    $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
    $0.backgroundColor = .systemBlue
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
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    setupMapView()
    setupModalUI()
    setupActions()
    updateButtonSelection()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 뷰가 사라질 때 등록 여부를 확인하는 if문
    if didRegister {
      print("✅ 등록 완료 후 화면이 닫힙니다.")
    } else {
      print("❌ 등록이 취소되었거나, 사용자가 화면을 닫았습니다.")
    }
  }

  // MARK: - UI Setup

  private func setupMapView() {
    let mapView = NMFNaverMapView()
    view.addSubview(mapView)
    mapView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    let marker = NMFMarker()
    marker.position = NMGLatLng(lat: latitude, lng: longitude)
    marker.mapView = mapView.mapView
  }

  private func setupModalUI() {
    view.addSubview(bottomModalView)
    bottomModalView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
    }

    for item in [closeButton, modalLabel, typeSelectionLabel, typeSelectionStackView, registerButton] {
      bottomModalView.addSubview(item)
    }

    closeButton.snp.makeConstraints {
      $0.top.equalToSuperview().offset(16)
      $0.trailing.equalToSuperview().inset(16)
    }

    modalLabel.snp.makeConstraints {
      $0.top.equalTo(closeButton.snp.bottom).offset(4)
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

    registerButton.snp.makeConstraints {
      $0.top.equalTo(typeSelectionStackView.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(200)
      $0.height.equalTo(44)
      $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }

  private func setupActions() {
    registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
    closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
  }

  // MARK: - Actions

  @objc private func didTapRegister() {
    didRegister = true // 등록 버튼 클릭 시 상태를 true로 변경

    let locationString = "\(latitude)/\(longitude)"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let nowString = dateFormatter.string(from: Date())

    let newID = repository.registKickboard(
      registerDate: nowString,
      location: locationString,
      detailLocation: "",
      type: Int16(selectedType)
    )

    print("✅ 킥보드 등록 완료: ID=\(newID), 위치=\(locationString), 타입=\(selectedType)")

    showAlert(title: "등록 완료", message: "새로운 킥보드가 성공적으로 등록되었습니다.") { [weak self] in
      guard let self else { return }
      delegate?.didRegisterKickBoard(at: latitude, longitude: longitude) // 마커 등록
      navigationController?.popViewController(animated: true) // 이전 뷰 (MapView)로 이동
    }
  }

  @objc private func didTapClose() {
    dismiss(animated: true, completion: nil)
  }

  @objc private func didTapTypeButton(_ sender: UIButton) {
    selectedType = sender.tag
    updateButtonSelection()
  }

  // MARK: - Helpers

  private func createTypeButton(title: String, imageName: String, tag: Int) -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle(title, for: .normal)

    // 이미지 로드 및 리사이즈
    if let originalImage = UIImage(named: imageName) {
      let newSize = CGSize(width: 50, height: 50) // 원하는 이미지 크기로 조절
      let renderer = UIGraphicsImageRenderer(size: newSize)
      let resizedImage = renderer.image { _ in
        originalImage.draw(in: CGRect(origin: .zero, size: newSize))
      }
      button.setImage(resizedImage, for: .normal)
    }

    button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    button.setTitleColor(.black, for: .normal)
    button.layer.cornerRadius = 12
    button.layer.borderWidth = 1
    button.layer.borderColor = UIColor.lightGray.cgColor
    button.backgroundColor = .white
    button.tag = tag
    button.addTarget(self, action: #selector(didTapTypeButton), for: .touchUpInside)
    button.alignTextBelow(spacing: 8)
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
    present(alert, animated: true)
  }
}

// UIButton Extension for text alignment
extension UIButton {
  func alignTextBelow(spacing: CGFloat) {
    guard let image = imageView?.image else {
      return
    }
    guard let titleLabel else {
      return
    }
    guard let titleText = titleLabel.text else {
      return
    }

    let titleSize = titleText.size(withAttributes: [
      NSAttributedString.Key.font: titleLabel.font as Any
    ])

    titleEdgeInsets = UIEdgeInsets(top: spacing, left: -image.size.width, bottom: -image.size.height, right: 0)
    imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
  }
}
