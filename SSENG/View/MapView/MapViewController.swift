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

  // UserDefaults 값
  private let selectedMarkerKey = "SelectedMarkerType"

  // 마커 저장 배열
  private var allMarkers: [NMFMarker] = []
  private var kickBoardMarkers: [NMFMarker] = []
  private var bikeMarkers: [NMFMarker] = []

  private var pendingKickBoard: Kickboard?

  // 맵 뷰
  let mapView = NMFMapView()

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

  // 마커 필터 버튼 스택뷰
  private let markerFilterStackView = UIStackView().then {
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

  // 전체 마커
  private let allMarkerButton = UIButton().then {
    $0.setImage(UIImage(systemName: "a.circle"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
    $0.tag = 0
  }

  // 닷 뷰
  private lazy var allMarkerIndicatorDot = makeIndicatorDotView()

  // 구분선 뷰
  private lazy var dividerView1 = makeDividerView()

  // 킥보드 마커
  private let kickBoardMarkerButton = UIButton().then {
    $0.setImage(UIImage(systemName: "k.circle"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
    $0.tag = 1
  }

  // 닷 뷰
  private lazy var kickBoardIndicatorDot = makeIndicatorDotView()

  // 구분선 뷰
  private lazy var dividerView2 = makeDividerView()

  // 오토바이 마커
  private let bikeMarkerButton = UIButton().then {
    $0.setImage(UIImage(systemName: "b.circle"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
    $0.tag = 2
  }

  // 닷 뷰
  private lazy var bikeIndicatorDot = makeIndicatorDotView()

  // 구분선 뷰
  private lazy var dividerView3 = makeDividerView()

  // 노마커
  private let noneMarkerButton = UIButton().then {
    $0.setImage(UIImage(systemName: "n.circle"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
    $0.tag = 3
  }

  // 닷 뷰
  private lazy var noneIndicatorDot = makeIndicatorDotView()

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
  private lazy var dividerView4 = makeDividerView()

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

  private let riddingButton = UIButton().then {
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    $0.setTitleColor(.white, for: .normal)
    $0.setTitle("대여하기", for: .normal)
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .main
  }

  // prepare 제약조건 저장 프로퍼티
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
    loadSelectedMarkerKey()
    locationManager.requestWhenInUseAuthorization()
  }

  // 화면이 켜졌을때 네이게이션바 안보이게 설정
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)

    // 위치 권한 상태를 확인하고, 필요할 때만 요청
    if locationManager.authorizationStatus == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    }
  }

  // 화면이 꺼질때 네비게이션바 보이게 설정
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }

  // MARK: - 뷰 추가

  private func setupUI() {
    [mapView, myPageButton, markerFilterStackView, controlStackView, rideKickBoardView].forEach { view.addSubview($0) }

    [reloadButton, dividerView4, locationButton].forEach { controlStackView.addArrangedSubview($0) }

    [allMarkerButton, dividerView1, kickBoardMarkerButton, dividerView2, bikeMarkerButton, dividerView3, noneMarkerButton].forEach { markerFilterStackView.addArrangedSubview($0) }

    [kickBoardHStackView, riddingButton].forEach { rideKickBoardView.addSubview($0) }

    [typeImageView, kickBoardVStackView].forEach { kickBoardHStackView.addArrangedSubview($0) }

    [batteryLabel, priceLabel, detailLocationTitleLabel, detailLocationLabel].forEach { kickBoardVStackView.addArrangedSubview($0) }

    allMarkerButton.addSubview(allMarkerIndicatorDot)
    kickBoardMarkerButton.addSubview(kickBoardIndicatorDot)
    bikeMarkerButton.addSubview(bikeIndicatorDot)
    noneMarkerButton.addSubview(noneIndicatorDot)
  }

  // MARK: - 제약조건

  private func setupConstraints() {
    mapView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }

    myPageButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.size.equalTo(50)
    }

    markerFilterStackView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.bottom.equalTo(controlStackView.snp.top).offset(-10)
      $0.width.equalTo(50)
    }

    allMarkerButton.snp.makeConstraints {
      $0.height.equalTo(50)
    }

    kickBoardMarkerButton.snp.makeConstraints {
      $0.height.equalTo(50)
    }

    bikeMarkerButton.snp.makeConstraints {
      $0.height.equalTo(50)
    }

    noneMarkerButton.snp.makeConstraints {
      $0.height.equalTo(50)
    }

    allMarkerIndicatorDot.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(40)
    }
    kickBoardIndicatorDot.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(40)
    }
    bikeIndicatorDot.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(40)
    }
    noneIndicatorDot.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.top.equalToSuperview().inset(40)
    }

    controlStackView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.bottom.equalToSuperview().inset(80).priority(.low)
      $0.bottom.lessThanOrEqualTo(rideKickBoardView.snp.top).offset(-20)
      $0.width.equalTo(50)
      $0.height.equalTo(100)
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

    riddingButton.snp.makeConstraints {
      $0.top.equalTo(kickBoardHStackView.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
    }
  }
}

// MARK: - Method

extension MapViewController {
  // 유저 디폴트 값 불러오기
  private func loadSelectedMarkerKey() {
    if let saved = UserDefaults.standard.string(forKey: selectedMarkerKey),
       let savedModel = SelectedMarkerModel(rawValue: saved)
    {
      selected = savedModel

      // 버튼 UI도 반영해줘야 하니까 switch로 처리
      switch savedModel {
      case .all: handleMarkerFilterButton(allMarkerButton)
      case .kickBoard: handleMarkerFilterButton(kickBoardMarkerButton)
      case .bike: handleMarkerFilterButton(bikeMarkerButton)
      case .none: handleMarkerFilterButton(noneMarkerButton)
      }
    } else {
      // 기본값은 all
      handleMarkerFilterButton(allMarkerButton)
    }
  }

  // 현재위치로 카메라 이동 메서드
  private func locationMove(nowLocation: CLLocationManager) {
    if let location = nowLocation.location {
      let lat = location.coordinate.latitude
      let lng = location.coordinate.longitude
      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: 16)
      cameraUpdate.animation = .fly
      cameraUpdate.animationDuration = 0.5
      mapView.positionMode = .normal
      mapView.moveCamera(cameraUpdate)
    } else {
      // 약간의 시간차를 두고 다시 시도
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        guard let self, let location = nowLocation.location else {
          print(" 위치를 가져오지 못했습니다.")
          return
        }
        let lat = location.coordinate.latitude
        let lng = location.coordinate.longitude
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: 16)
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 0.5
        self.mapView.moveCamera(cameraUpdate)
      }
    }
  }

  // 마커 클릭시 카메라 이동
  private func moveMarker(kickBoard: Kickboard) {
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: kickBoard.lat, lng: kickBoard.lng), zoomTo: 16)
    cameraUpdate.animation = .easeIn
    cameraUpdate.animationDuration = 0.3
    mapView.moveCamera(cameraUpdate)
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

    if kickBoard.kickboardType == .kickboard {
      typeImageView.image = UIImage(resource: .kickboard)
      priceLabel.text = "분당: 100원"
    } else {
      typeImageView.image = UIImage(resource: .bike)
      priceLabel.text = "분당: 1000원"
    }

    batteryLabel.attributedText = batteryStatusText(for: Int(kickBoard.battery), batteryTime: kickBoard.batteryTime)
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
    kickBoardMarkers.removeAll()
    bikeMarkers.removeAll()

    let kickBoardRepository = KickboardRepository()
    let kickboards = kickBoardRepository.readAllKickboards()

    guard !kickboards.isEmpty else {
      print("🔵 CoreData: 저장된 킥보드 데이터가 없습니다.")
      return
    }

    for kickboard in kickboards {
      let marker = createMarker(for: kickboard)
      allMarkers.append(marker)

      if kickboard.kickboardType == .kickboard {
        kickBoardMarkers.append(marker)
      } else {
        bikeMarkers.append(marker)
      }
    }

    updateVisibleMarkers()
    print("킥보드 마커 등록 완료")
  }

  // 마커 필터링 데이터 업데이트
  private func updateVisibleMarkers() {
    for marker in allMarkers {
      marker.mapView = nil
    }

    let visibleBounds = mapView.contentBounds

    switch selected {
    case .all:
      for marker in allMarkers {
        let position = marker.position
        if visibleBounds.hasPoint(position) {
          marker.mapView = mapView
        }
      }
    case .kickBoard:
      for kickBoardMarker in kickBoardMarkers {
        let position = kickBoardMarker.position
        if visibleBounds.hasPoint(position) {
          kickBoardMarker.mapView = mapView
        }
      }
    case .bike:
      for bikeMarker in bikeMarkers {
        let position = bikeMarker.position
        if visibleBounds.hasPoint(position) {
          bikeMarker.mapView = mapView
        }
      }
    case .none:
      break
    }
  }

  // 마커 생성하기
  private func createMarker(for kickboard: Kickboard) -> NMFMarker {
    let marker = NMFMarker()
    marker.position = NMGLatLng(lat: kickboard.lat, lng: kickboard.lng)

    if kickboard.kickboardType == .kickboard {
      if kickboard.battery >= 70 {
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .kickboardFull))
      } else if kickboard.battery >= 31 {
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .kickBoardMiddle))
      } else {
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .kickboardLow))
      }
    } else {
      if kickboard.battery >= 70 {
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .bikeFull))
      } else if kickboard.battery >= 31 {
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .bikeMiddle))
      } else {
        marker.iconImage = NMFOverlayImage(image: UIImage(resource: .bikeLow))
      }
    }

    marker.userInfo = ["kickboard": kickboard]
    marker.isForceShowIcon = true
    marker.width = 42.5
    marker.height = 42.5
    marker.captionOffset = 8

    marker.touchHandler = { [weak self] _ in
      self?.pendingKickBoard = kickboard
      self?.moveMarker(kickBoard: kickboard)
      return true
    }
    return marker
  }

  // 배터리 상태에 따라 아이콘과 텍스트를 반환하는 메서드
  private func batteryStatusText(for batteryLevel: Int, batteryTime: String) -> NSAttributedString {
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
    fullString.append(NSAttributedString(string: " \(batteryLevel)% (\(batteryTime))"))
    return fullString
  }

  // 구분선 뷰 생성 메서드
  func makeDividerView() -> UIView {
    UIView().then {
      $0.backgroundColor = .lightGray
      $0.snp.makeConstraints { $0.height.equalTo(1) }
    }
  }

  // 닷 뷰 생성 메서드
  private func makeIndicatorDotView() -> UIView {
    UIView().then {
      $0.backgroundColor = .clear
      $0.layer.cornerRadius = 3
      $0.snp.makeConstraints { $0.height.width.equalTo(6) }
    }
  }
}

// MARK: - Action

extension MapViewController {
  private func setupButtonActions() {
    myPageButton.addTarget(self, action: #selector(didTabMyPageButton), for: .touchUpInside)
    allMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    kickBoardMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    bikeMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    noneMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    reloadButton.addTarget(self, action: #selector(didTabReloadButton), for: .touchUpInside)
    locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
    //    rideingButton.addTarget(self, action: #selector(didTapRideingButton), for: .touchUpInside)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDetailLocationLabelTap))
    detailLocationLabel.addGestureRecognizer(tapGesture)
  }

  // 마이페이지 버튼 액션
  @objc private func didTabMyPageButton() {
    let myPageVC = MypageViewController()
    navigationController?.pushViewController(myPageVC, animated: true)
  }

  // 마커 필터링 액션
  @objc private func handleMarkerFilterButton(_ sender: UIButton) {
    for (index, dot) in [allMarkerIndicatorDot, kickBoardIndicatorDot, bikeIndicatorDot, noneIndicatorDot].enumerated() {
      dot.backgroundColor = (index == sender.tag) ? .main : .clear
    }

    switch sender.tag {
    case 0: selected = .all
    case 1: selected = .kickBoard
    case 2: selected = .bike
    case 3: selected = .none
    default: break
    }

    // UesrDefaults에 필터링 상태 저장
    UserDefaults.standard.set(selected.rawValue, forKey: selectedMarkerKey)
    // 마커 업데이트
    updateVisibleMarkers()
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
  // 위치권한 확인
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      print("위치 권한 허용됨")
      locationMove(nowLocation: manager) // 권한 허용 즉시 위치 이동
    case .denied, .restricted:
      print("위치 권한 거부됨")
    case .notDetermined:
      break
    @unknown default:
      break
    }
  }

  // 현재 위치 움직임 감지
  func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    mapView.positionMode = .direction

    guard let location = locations.last else { return }
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude), zoomTo: 16)

    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 0.5
    mapView.moveCamera(cameraUpdate)

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

  func mapViewCameraIdle(_: NMFMapView) {
    print("카메라 정지")
    if let kickboard = pendingKickBoard {
      showKickBoardView(kickBoard: kickboard)
      pendingKickBoard = nil
    }

    updateVisibleMarkers()
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
