//
//  MapViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import CoreData
import CoreLocation
import NMapsMap
import SnapKit
import Then
import UIKit

class MapViewController: UIViewController {
  // 선택된 마커
  var selected: SelectedMarkerModel = .all
  // 마커 저장 배열
  private var allMarkers: [NMFMarker] = []
  private var kickBoardMarkers: [NMFMarker] = []
  private var bikeMarkers: [NMFMarker] = []

  // 맵 뷰
  let mapView = NMFMapView().then {
    $0.positionMode = .normal
  }

  // 위치
  let locationManager = CLLocationManager()

  // 마이페이지 버튼
  private let myPageButton = UIButton().then {
    $0.setImage(UIImage(systemName: "person"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = false
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    $0.layer.shadowRadius = 4
  }

  // 새로고침, 위치추적 버튼 스택뷰
  private let controlStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
    $0.distribution = .fillProportionally
    $0.layer.cornerRadius = 12
    $0.backgroundColor = UIColor.white.withAlphaComponent(0.7)
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.2
    $0.layer.shadowOffset = CGSize(width: 0, height: 2)
    $0.layer.shadowRadius = 4
  }

  // 새로고침 버튼
  private let reloadButton = UIButton().then {
    $0.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
  }

  // 구분선 뷰
  private let dividerView = UIView().then {
    $0.backgroundColor = .lightGray
  }

  // 위치 버튼
  private let locationButton = UIButton().then {
    $0.setImage(UIImage(systemName: "location"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
  }

  // 킥보드 정보 뷰
  private let rideKickBoardView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: -2)
    $0.layer.shadowRadius = 6
  }

  private let kickBoardHStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.alignment = .center
    $0.spacing = 15
  }

  private let kickBoardVStackView = UIStackView().then {
    $0.axis = .vertical
    $0.distribution = .fillEqually
    $0.spacing = 8
  }

  // 타입별 이미지
  private let typeImageView = UIImageView().then {
    $0.contentMode = .scaleAspectFit
  }

  // 배터리
  private let batteryLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 12, weight: .bold)
  }

  // 가격
  private let priceLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 12, weight: .bold)
  }

  // 상세위치
  private let detailLocationTitleLabel = UILabel().then {
    $0.textColor = .black
    $0.text = "- 상세 위치 -"
    $0.font = .systemFont(ofSize: 12, weight: .bold)
  }

  private let detailLocationLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 12)
    $0.isUserInteractionEnabled = true
  }

  private let rideingButton = UIButton().then {
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    $0.setTitleColor(.white, for: .normal)
    $0.setTitle("대여하기", for: .normal)
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .main
  }

  var rideKickBoardViewShowConstraint: [Constraint] = []
  var rideKickBoardViewHiddenConstraint: [Constraint] = []
  var controlStackViewConstraint: [Constraint] = []

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.addCameraDelegate(delegate: self)
    mapView.touchDelegate = self
    locationManager.delegate = self

    setupUI()
    setupConstraints()
    setupButtonActions()
    allKickBoardMarker()

    locationManager.requestWhenInUseAuthorization()
  }

  // 화면이 켜졌을때 네이게이션바 안보이게 설정
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  // 화면이 꺼질때 네비게이션바 보이게 설정
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }

  // 뷰 추가
  private func setupUI() {
    [mapView, controlStackView, myPageButton, rideKickBoardView].forEach { view.addSubview($0) }
    [reloadButton, dividerView, locationButton].forEach { controlStackView.addArrangedSubview($0) }
    [kickBoardHStackView, rideingButton].forEach { rideKickBoardView.addSubview($0) }
    [typeImageView, kickBoardVStackView].forEach { kickBoardHStackView.addArrangedSubview($0) }
    [batteryLabel, priceLabel, detailLocationTitleLabel, detailLocationLabel].forEach { kickBoardVStackView.addArrangedSubview($0) }
  }

  // 제약조건
  private func setupConstraints() {
    mapView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    controlStackView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(80).priority(.low)
      $0.bottom.lessThanOrEqualTo(rideKickBoardView.snp.top).offset(-20)
      $0.width.equalTo(50)
      $0.height.equalTo(100)
    }

    dividerView.snp.makeConstraints {
      $0.height.equalTo(1)
    }

    myPageButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.size.equalTo(50)
    }

    typeImageView.snp.makeConstraints {
      $0.height.equalTo(80)
    }

    rideKickBoardView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.25)
    }

    rideKickBoardViewShowConstraint = rideKickBoardView.snp.prepareConstraints {
      $0.bottom.equalToSuperview()
    }

    rideKickBoardViewHiddenConstraint = rideKickBoardView.snp.prepareConstraints {
      $0.top.equalTo(view.snp.bottom)
    }
    for constraint in rideKickBoardViewHiddenConstraint {
      constraint.isActive = true
    }

    kickBoardHStackView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview().inset(20)
    }

    rideingButton.snp.makeConstraints {
      $0.top.equalTo(kickBoardHStackView.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
    }
  }

  // 킥보드 정보창 띄우기
  private func showKickBoardView(kickBoard: Kickboard) {
    for constraint in rideKickBoardViewHiddenConstraint {
      constraint.isActive = false
    }
    for constraint in rideKickBoardViewShowConstraint {
      constraint.isActive = true
    }
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }

    print("마커 클릭됨!")

    if kickBoard.type == 1 {
      typeImageView.image = UIImage(resource: .kickboard)
      priceLabel.text = "분당: 100원"
    } else {
      typeImageView.image = UIImage(resource: .bike)
      priceLabel.text = "분당: 1000원"
    }
    batteryLabel.attributedText = batteryStatusAttributedText(for: Int(kickBoard.battery))
    detailLocationLabel.text = "\(kickBoard.detailLocation ?? "정보 없음")"
  }

  // 킥보드정보 창 가리기
  private func hiddenKickBoardView() {
    for constraint in rideKickBoardViewShowConstraint {
      constraint.isActive = false
    }
    for constraint in rideKickBoardViewHiddenConstraint {
      constraint.isActive = true
    }
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
    print("사용자 이벤트 발생 탭 또는 스크롤됨! ")
  }

  // 킥보드 전체 데이터 받아와서 킥보드 마커 등록
  private func allKickBoardMarker() {
    for marker in allMarkers {
      marker.mapView = nil
    }
    allMarkers.removeAll()
    let kickBoardRepository = KickboardRepository()
    let kickboards = kickBoardRepository.readAllKickboards()
    if kickboards.isEmpty {
      // TODO: - 팝업창으로 띄우기
      print("🔵 CoreData: 저장된 킥보드 데이터가 없습니다.")
    } else {
      for kickboard in kickboards {
        addKickboardMarkers(kickboard: kickboard)
      }
      print("킥보드 마커 등록 완료")
    }
  }

  // 킥보드 마커 추가
  func addKickboardMarkers(kickboard: Kickboard) {
    let marker = NMFMarker()
    guard let latLng = kickboard.location?.split(separator: "/") else { return }
    marker.position = NMGLatLng(lat: Double(latLng[0]) ?? 0.0, lng: Double(latLng[1]) ?? 0.0)
    if kickboard.type == 1 {
      if kickboard.battery >= 70 {
        let image = UIImage(resource: .kickboardFull)
        marker.iconImage = NMFOverlayImage(image: image)
      } else if kickboard.battery >= 31 {
        let image = UIImage(resource: .kickBoardMiddle)
        marker.iconImage = NMFOverlayImage(image: image)
      } else {
        let image = UIImage(resource: .kickboardLow)
        marker.iconImage = NMFOverlayImage(image: image)
      }
    } else {
      let image = UIImage(resource: .bike)
      marker.iconImage = NMFOverlayImage(image: image)
      if kickboard.battery >= 70 {
        let image = UIImage(resource: .bikeFull)
        marker.iconImage = NMFOverlayImage(image: image)
      } else if kickboard.battery >= 31 {
        let image = UIImage(resource: .bikeMiddle)
        marker.iconImage = NMFOverlayImage(image: image)
      } else {
        let image = UIImage(resource: .bikeLow)
        marker.iconImage = NMFOverlayImage(image: image)
      }
    }

    marker.userInfo = ["kickboard": kickboard]
    marker.isForceShowIcon = true
    marker.width = 42.5
    marker.height = 42.5
    marker.captionOffset = 8
    marker.mapView = mapView
    marker.touchHandler = { [weak self] _ in
      self?.showKickBoardView(kickBoard: kickboard)
      return true
    }
    allMarkers.append(marker)
  }

  // 배터리 상태에 따라 아이콘과 텍스트를 반환하는 메서드
  private func batteryStatusAttributedText(for batteryLevel: Int) -> NSAttributedString {
    let imageAttachment = NSTextAttachment()
    if batteryLevel == 100 {
      imageAttachment.image = UIImage(systemName: "battery.100percent")
    } else if batteryLevel >= 51 {
      imageAttachment.image = UIImage(systemName: "battery.75percent")
    } else if batteryLevel >= 26 {
      imageAttachment.image = UIImage(systemName: "battery.50percent")
    } else {
      imageAttachment.image = UIImage(systemName: "battery.25percent")
    }

    let fullString = NSMutableAttributedString(attachment: imageAttachment)
    fullString.append(NSAttributedString(string: " \(batteryLevel)%"))
    return fullString
  }

  // MARK: - Action

  private func setupButtonActions() {
    myPageButton.addTarget(self, action: #selector(didTabMyPageButton), for: .touchUpInside)
    reloadButton.addTarget(self, action: #selector(didTabReloadButton), for: .touchUpInside)
    locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
//    rideingButton.addTarget(self, action: #selector(didTapRideingButton), for: .touchUpInside)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDetailLocationLabelTap))
    detailLocationLabel.addGestureRecognizer(tapGesture)
  }

  // 마이페이지 버튼 액션
  @objc private func didTabMyPageButton() {
    let myPageVC = MypageViewcontroller()
    navigationController?.pushViewController(myPageVC, animated: true)
  }

  // 새로고침 버튼 액션
  @objc private func didTabReloadButton() {
    print("Reload Tapped")
    allKickBoardMarker()
  }

  // 위치 추적 버튼 액션
  @objc private func didTapLocationButton() {
    print("Location Tapped")
    locationManager.startUpdatingLocation()
  }

  // 상세위치 탭 제스처 액션
  @objc private func handleDetailLocationLabelTap() {
    let alert = UIAlertController(
      title: "상세 위치",
      message: detailLocationLabel.text,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "확인", style: .default))
    present(alert, animated: true)
  }
}

// MARK: - Location Delegate

extension MapViewController: CLLocationManagerDelegate {
  // 현재 위치 움직임 감지
  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    let latLng = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)

    let cameraPosition = NMFCameraPosition(latLng, zoom: 16)
    let cameraUpdate = NMFCameraUpdate(position: cameraPosition)

    mapView.moveCamera(cameraUpdate)
    mapView.positionMode = .compass

    print("카메라 업데이트: \(cameraUpdate)")
  }
}

// MARK: - Camera Delegate

extension MapViewController: NMFMapViewCameraDelegate {
  // 카메라 이동 됐을때
  func mapView(_: NMFMapView, cameraIsChangingByReason reason: Int) {
    print("카메라 이동: \(reason)")
    hiddenKickBoardView()
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - Touch Delegate

extension MapViewController: NMFMapViewTouchDelegate {
  // 지도를 길게 눌렀을때
  func mapView(_: NMFMapView, didLongTapMap latlng: NMGLatLng, point _: CGPoint) {
    print("롱 탭: \(latlng.lat), \(latlng.lng)")
    let addKickBoardVC = KickBoardViewController(latitude: latlng.lat, longitude: latlng.lng)
    addKickBoardVC.delegate = self
    navigationController?.pushViewController(addKickBoardVC, animated: true)
  }

  // 지도를 짧게 눌렀을때
  func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
    print("숏 탭: \(latlng.lat), \(latlng.lng)")
    hiddenKickBoardView()
  }
}

// MARK: - KickBoardView Delegate

extension MapViewController: KickBoardViewControllerDelegate {
  // 킥보드 등록 완료 됐는지 추적하여 완료 됐을경우 킥보드 마커 등록
  func didRegisterKickBoard(at _: Double, longitude _: Double) {
    allKickBoardMarker()
  }
}

// TODO: - 지도 API 받아오지 못 했을 경우 에러처리

// @available(iOS 17.0, *)
// #Preview {
//  MapViewController()
// }
