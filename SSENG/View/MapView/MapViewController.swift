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
  // 마커 저장 배열
  private var kickboardMarkers: [NMFMarker] = []
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

  var rideKickBoardViewShowConstraint: [Constraint] = []
  var rideKickBoardViewHiddenConstraint: [Constraint] = []
  var controlStackViewConstraint: [Constraint] = []

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

    rideKickBoardView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(200)
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
  }

  // 킥보드 정보창 띄우기
  private func showKickBoardView() {
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
    for marker in kickboardMarkers {
      marker.mapView = nil
    }
    kickboardMarkers.removeAll()
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
    marker.iconTintColor = .black
    marker.isForceShowIcon = true
    marker.width = 42.5
    marker.height = 42.5
    marker.captionOffset = 8
    marker.mapView = mapView
    marker.touchHandler = { [weak self] _ in
      self?.showKickBoardView()
      return true
    }
    kickboardMarkers.append(marker)
  }

  // MARK: - Action

  private func setupButtonActions() {
    myPageButton.addTarget(self, action: #selector(didTabMyPageButton), for: .touchUpInside)
    reloadButton.addTarget(self, action: #selector(didTabReloadButton), for: .touchUpInside)
    locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
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
