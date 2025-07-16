//
//  MapViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import CoreLocation
import NMapsMap
import SnapKit
import Then
import UIKit

class MapViewController: UIViewController {
  // 맵 뷰
  let mapView = NMFMapView().then {
    $0.positionMode = .normal
  }

  // 위치
  let locationManager = CLLocationManager()

  // 킥보드 등록 버튼
  private let addKickBoardButton = UIButton().then {
    $0.setImage(UIImage(systemName: "plus"), for: .normal)
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

  override func viewDidLoad() {
    super.viewDidLoad()

    mapView.addCameraDelegate(delegate: self)
    mapView.touchDelegate = self
    locationManager.delegate = self

    setupUI()
    setupConstraints()
    setupButtonActions()

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

  private func setupUI() {
    [mapView, controlStackView, addKickBoardButton, myPageButton].forEach { view.addSubview($0) }
    [reloadButton, dividerView, locationButton].forEach { controlStackView.addArrangedSubview($0) }
  }

  private func setupButtonActions() {
    addKickBoardButton.addTarget(self, action: #selector(didTabAddKickBoardButton), for: .touchUpInside)
    myPageButton.addTarget(self, action: #selector(didTabMyPageButton), for: .touchUpInside)
    reloadButton.addTarget(self, action: #selector(didTabReloadButton), for: .touchUpInside)
    locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
  }

  private func setupConstraints() {
    mapView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    controlStackView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(80)
      $0.width.equalTo(50)
      $0.height.equalTo(100)
    }

    dividerView.snp.makeConstraints {
      $0.height.equalTo(1)
    }

    addKickBoardButton.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(20)
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.size.equalTo(50)
    }

    myPageButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.size.equalTo(50)
    }
  }

  // 킥보드 등록 버튼 액션
  @objc private func didTabAddKickBoardButton() {}

  // 마이페이지 버튼 액션
  @objc private func didTabMyPageButton() {
    let myPageVC = MypageViewcontroller()
    navigationController?.pushViewController(myPageVC, animated: true)
  }

  // 새로고침 버튼 액션
  @objc private func didTabReloadButton() {}

  // 위치 추적 버튼 액션
  @objc private func didTapLocationButton() {
    locationManager.startUpdatingLocation()
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    let latLng = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)

    let cameraPosition = NMFCameraPosition(latLng, zoom: 16)
    let cameraUpdate = NMFCameraUpdate(position: cameraPosition)

    mapView.moveCamera(cameraUpdate)
    mapView.positionMode = .direction

    print("카메라 업데이트: \(cameraUpdate)")
  }
}

extension MapViewController: NMFMapViewCameraDelegate {
  func mapView(_: NMFMapView, cameraIsChangingByReason reason: Int) {
    print("카메라 이동: \(reason)")
    locationManager.stopUpdatingLocation()
  }
}

extension MapViewController: NMFMapViewTouchDelegate {
  func mapView(_: NMFMapView, didLongTapMap latlng: NMGLatLng, point _: CGPoint) {
    print("롱 탭: \(latlng.lat), \(latlng.lng)")

    let addKickBoardVC = KickBoardViewController(latitude: latlng.lat, longitude: latlng.lng)
    navigationController?.pushViewController(addKickBoardVC, animated: true)
  }
}

// TODO: - 지도 API 받아오지 못 했을 경우 에러처리

// @available(iOS 17.0, *)
// #Preview {
//  MapViewController()
// }
