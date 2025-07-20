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
  // 검색Service
  private let searchService = SearchService()
  private var places: [Place] = []

  // 선택된 마커
  var selected: SelectedMarkerModel = .all

  // UserDefaults 값
  private let selectedMarkerKey = "SelectedMarkerType"

  // 코어데이터
  let kickBoardRepository = KickboardRepository()

  // 마커 데이터
  private var allMarkers: [NMFMarker] = []
  private var kickBoardMarkers: [NMFMarker] = []
  private var bikeMarkers: [NMFMarker] = []
  private var selectedKickBoard: Kickboard?
  private var riddingKickBoard: Kickboard?

  // 타이머
  private var timer: Timer?
  private var secondsElapsed: Int = 0

  // 맵 뷰
  let mapView = NMFMapView()

  // 위치
  let locationManager = CLLocationManager()

  // 검색창
  private let searchBar = UISearchBar().then {
    $0.placeholder = "주소 검색"
    $0.searchBarStyle = .minimal
  }

  private lazy var searchCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
    $0.itemSize = CGSize(width: UIScreen.main.bounds.width - 80, height: 80)
    $0.sectionInset = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
  }).then {
    $0.showsVerticalScrollIndicator = false
    $0.register(SearchResultCell.self, forCellWithReuseIdentifier: SearchResultCell.identifier)
    $0.dataSource = self
    $0.backgroundColor = .systemGray6
    $0.layer.cornerRadius = 12
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
  private let kickBoardInfoView = UIView().then {
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

  // 대여하기
  private let riddingButton = UIButton().then {
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    $0.setTitleColor(.white, for: .normal)
    $0.setTitle("대여하기", for: .normal)
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .main
    $0.isEnabled = true
  }

  // 탑승중 뷰
  private let riddingView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 16
    $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOpacity = 0.3
    $0.layer.shadowOffset = CGSize(width: 0, height: -2)
    $0.layer.shadowRadius = 6
  }

  // 스톱워치
  private let stopwatchLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .monospacedDigitSystemFont(ofSize: 20, weight: .bold)
  }

  // 남은 배터리
  private let riddingBatteryLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 15, weight: .bold)
  }

  // 사용 가격
  private let riddingPriceLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 15, weight: .bold)
  }

  // 반납하기
  private let returnButton = UIButton().then {
    $0.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
    $0.setTitleColor(.white, for: .normal)
    $0.setTitle("반납하기", for: .normal)
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .main
  }

  // prepare 제약조건 저장 프로퍼티
  var kickBoardInfoViewShowConstraint: [Constraint] = []
  var kickBoardIfoViewHiddenConstraint: [Constraint] = []
  var controlStackViewConstraint: [Constraint] = []
  var riddingViewShowConstraint: [Constraint] = []
  var riddingViewHiddenConstraint: [Constraint] = []
  var heightConstraint: [Constraint] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    searchBar.delegate = self
    searchCollectionView.delegate = self
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
    [mapView, searchBar, searchCollectionView, myPageButton, markerFilterStackView, controlStackView, riddingView, kickBoardInfoView].forEach { view.addSubview($0) }

    [reloadButton, dividerView4, locationButton].forEach { controlStackView.addArrangedSubview($0) }

    [allMarkerButton, dividerView1, kickBoardMarkerButton, dividerView2, bikeMarkerButton, dividerView3, noneMarkerButton].forEach { markerFilterStackView.addArrangedSubview($0) }

    [kickBoardHStackView, riddingButton].forEach { kickBoardInfoView.addSubview($0) }

    [typeImageView, kickBoardVStackView].forEach { kickBoardHStackView.addArrangedSubview($0) }

    [batteryLabel, priceLabel, detailLocationTitleLabel, detailLocationLabel].forEach { kickBoardVStackView.addArrangedSubview($0) }

    [stopwatchLabel, riddingBatteryLabel, riddingPriceLabel, returnButton].forEach { riddingView.addSubview($0) }

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

    searchBar.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
      $0.height.equalTo(50)
    }

    searchCollectionView.snp.makeConstraints {
      $0.top.equalTo(searchBar.snp.bottom)
      $0.leading.trailing.equalTo(searchBar).inset(5)
      $0.height.equalTo(0).priority(.low)
    }

    heightConstraint = searchCollectionView.snp.prepareConstraints {
      $0.height.equalTo(250)
    }

    myPageButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.top.equalTo(searchCollectionView.snp.bottom).offset(20)
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
      $0.bottom.lessThanOrEqualTo(kickBoardInfoView.snp.top).offset(-20)
      $0.bottom.lessThanOrEqualTo(riddingView.snp.top).offset(-20)
      $0.width.equalTo(50)
      $0.height.equalTo(100)
    }

    typeImageView.snp.makeConstraints {
      $0.height.equalTo(80)
    }

    kickBoardInfoView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.25)
    }

    kickBoardInfoViewShowConstraint = kickBoardInfoView.snp.prepareConstraints {
      $0.bottom.equalToSuperview()
    }

    kickBoardIfoViewHiddenConstraint = kickBoardInfoView.snp.prepareConstraints {
      $0.top.equalTo(view.snp.bottom)
    }

    for constraint in kickBoardIfoViewHiddenConstraint {
      constraint.isActive = true
    }

    kickBoardHStackView.snp.makeConstraints {
      $0.leading.top.trailing.equalToSuperview().inset(20)
    }

    riddingButton.snp.makeConstraints {
      $0.top.equalTo(kickBoardHStackView.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    riddingView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.height.equalToSuperview().multipliedBy(0.2)
    }

    stopwatchLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    riddingPriceLabel.snp.makeConstraints {
      $0.top.equalTo(stopwatchLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview().inset(20)
    }

    riddingBatteryLabel.snp.makeConstraints {
      $0.top.equalTo(stopwatchLabel.snp.bottom).offset(10)
      $0.trailing.equalToSuperview().inset(20)
    }

    returnButton.snp.makeConstraints {
      $0.top.equalTo(riddingPriceLabel.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview().inset(20)
    }

    riddingViewShowConstraint = riddingView.snp.prepareConstraints {
      $0.bottom.equalToSuperview()
    }

    riddingViewHiddenConstraint = riddingView.snp.prepareConstraints {
      $0.top.equalTo(view.snp.bottom)
    }

    for constraint in riddingViewHiddenConstraint {
      constraint.isActive = true
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

  // 검색
  func searchData(query: String) {
    searchService.search(query: query) { result in
      switch result {
      case let .success(places):
        for place in places {
          print("📍 \(place.title) - \(place.address)")
          self.places = places
          self.showCollectionView()
        }
      case let .failure(error):
        print("❌ 검색 실패: \(error)")
      }
    }
  }

  // 검색된 장소 데이터를 업데이트하고 컬렉션뷰 새로고침
  func update(with places: [Place]) {
    self.places = places
    DispatchQueue.main.async {
      self.searchCollectionView.reloadData()
    }
    print("데이터 새로고침 완료")
  }

  // 검색결과 창 띄우기
  func showCollectionView() {
    for constraint in heightConstraint {
      constraint.isActive = true
    }

    update(with: places)

    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
    }
  }

  // 검색결과 창 숨기기
  func hiddenCollectionView() {
    for constraint in heightConstraint {
      constraint.isActive = false
    }

    UIView.animate(withDuration: 0.25) {
      self.view.layoutIfNeeded()
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

  // 킥보드 정보창 띄우기
  private func showKickBoardView(kickBoard: Kickboard) {
    selectedKickBoard = kickBoard
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: kickBoard.lat, lng: kickBoard.lng), zoomTo: 16)
    cameraUpdate.animation = .easeIn
    cameraUpdate.animationDuration = 0.3
    mapView.moveCamera(cameraUpdate)

    for constraint in kickBoardIfoViewHiddenConstraint {
      constraint.isActive = false
    }

    for constraint in kickBoardInfoViewShowConstraint {
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
    for constraint in kickBoardInfoViewShowConstraint {
      constraint.isActive = false
    }

    for constraint in kickBoardIfoViewHiddenConstraint {
      constraint.isActive = true
    }

    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }

  // 탑승창 띄우기
  private func showRiddingView(kickBoard: Kickboard) {
    // 킥보드 정보창 숨기기
    hiddenKickBoardView()

    for constraint in riddingViewHiddenConstraint {
      constraint.isActive = false
    }

    for constraint in riddingViewShowConstraint {
      constraint.isActive = true
    }

    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }

    // 탑승 중일때 다른 킥보드 대여 못하게 및 창이 내려간 후에 바뀌게
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.riddingButton.isEnabled = false
      self.riddingButton.backgroundColor = .lightGray
      self.riddingButton.setTitle("기기를 반납 후 이용해주세요.", for: .normal)
    }
    // 스톱워치 초기화
    secondsElapsed = 0
    timer?.invalidate() // 혹시 모를 기존 타이머 제거
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    updateTime() // 타이머 시작 즉시 한 번 실행
    riddingBatteryLabel.attributedText = batteryStatusText(for: Int(kickBoard.battery), batteryTime: kickBoard.batteryTime)

    print("대여 시작!!")
  }

  // 탑승 창 가리기
  private func hiddenRiddingView() {
    selectedKickBoard = nil
    for constraint in riddingViewShowConstraint {
      constraint.isActive = false
    }

    for constraint in riddingViewHiddenConstraint {
      constraint.isActive = true
    }

    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }

    print("반납 완료!!")
  }

  // 킥보드 전체 데이터 받아와서 킥보드 마커 등록
  private func allKickBoardMarker() {
    for marker in allMarkers {
      marker.mapView = nil
    }

    allMarkers.removeAll()
    kickBoardMarkers.removeAll()
    bikeMarkers.removeAll()

    let kickboards = kickBoardRepository.readAllKickboards()

    guard !kickboards.isEmpty else {
      print("🔵 CoreData: 저장된 킥보드 데이터가 없습니다.")
      return
    }

    // 지도에 띄울때 탑승중이 아닌 것만 띄우기
    for kickboard in kickboards where kickboard.isRented == false {
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
      self?.showKickBoardView(kickBoard: kickboard)
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
    // 마이페이지 버튼
    myPageButton.addTarget(self, action: #selector(didTabMyPageButton), for: .touchUpInside)
    // 필터링: 전체
    allMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    // 필터링 버튼: 킥보드
    kickBoardMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    // 필터링 버튼: 오토바이
    bikeMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    // 필터링 버튼: 없음
    noneMarkerButton.addTarget(self, action: #selector(handleMarkerFilterButton(_:)), for: .touchUpInside)
    // 새로고침 버튼
    reloadButton.addTarget(self, action: #selector(didTabReloadButton), for: .touchUpInside)
    // 위치 추적 버튼
    locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
    // 대여하기 버튼
    riddingButton.addTarget(self, action: #selector(didTapRideingButton), for: .touchUpInside)
    // 상세 위치 보기 제스처
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDetailLocationLabelTap))
    detailLocationLabel.addGestureRecognizer(tapGesture)
    // 반납하기 버튼
    returnButton.addTarget(self, action: #selector(didTapReturnButton), for: .touchUpInside)
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

  // 대여하기 버튼 액션
  @objc private func didTapRideingButton() {
    riddingKickBoard = selectedKickBoard
    selectedKickBoard = nil

    guard let kickBoard = riddingKickBoard else {
      print("대여할 킥보드 정보가 없습니다.")
      return
    }

    let alert = UIAlertController(
      title: "킥보드 대여",
      message: "해당 킥보드를 대여하시겠습니까?",
      preferredStyle: .alert
    )

    // 확인 버튼 클릭 시 대여 실행
    let confirm = UIAlertAction(title: "대여하기", style: .default) { _ in
      self.kickBoardRepository.rentKickboard(id: kickBoard.id ?? "id가 없습니다.")
      self.allKickBoardMarker()
      self.locationManager.startUpdatingLocation()
      self.showRiddingView(kickBoard: kickBoard)
    }

    let cancel = UIAlertAction(title: "취소", style: .cancel)

    alert.addAction(confirm)
    alert.addAction(cancel)

    present(alert, animated: true)
  }

  // 스톱워치 액션
  @objc private func updateTime() {
    secondsElapsed += 1
    let hours = secondsElapsed / 3600
    let min = (secondsElapsed % 3600) / 60
    let sec = secondsElapsed % 60

    stopwatchLabel.text = String(format: "%02d:%02d:%02d 이용 중", hours, min, sec)

    if riddingKickBoard?.kickboardType == .kickboard {
      riddingPriceLabel.text = "\(100 * min)원"
    } else {
      riddingPriceLabel.text = "\(1000 * min)원"
    }
  }

  // 반납하기 버튼 액션
  @objc private func didTapReturnButton() {
    // 타이머 멈추기
    timer?.invalidate()

    guard riddingKickBoard != nil else {
      print("반납할 킥보드 정보가 없습니다.")
      return
    }

    guard let location = locationManager.location else {
      print("현재 위치 정보가 없습니다.")
      return
    }
    let lat = location.coordinate.latitude
    let lng = location.coordinate.longitude
    print("현 위치 위도: \(lat), 경도: \(lng)")

    let alert = UIAlertController(
      title: "반납 위치 입력",
      message: "상세 위치를 입력해주세요",
      preferredStyle: .alert
    )

    var confirmAction: UIAlertAction?

    alert.addTextField { textField in
      textField.placeholder = "예: 건물 앞 자전거 거치대"

      NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { _ in
        guard let text = textField.text,
              let confirm = confirmAction else { return }

        confirm.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
      }
    }

    // 확인 버튼 클릭시 반납 처리 실행
    let confirm = UIAlertAction(title: "반납하기", style: .default) { _ in
      let text = alert.textFields?.first?.text ?? "위치 정보 없음"
      print("입력된 위치: \(text)")
      self.detailLocationLabel.text = text
      self.kickBoardRepository.returnKickboard(id: self.riddingKickBoard?.id ?? "데이터가 없습니다.", lat: lat, lng: lng, detailLocation: self.detailLocationLabel.text ?? "데이터가 없습니다")

      let kickBoardHistory = HistoryRepository()
      guard let userID = UserDefaults.standard.string(forKey: "loggedUserID") else {
        print("유저 데이터를 불러오지 못했습니다.")
        return
      }

      let nowTime = Date()
      let startTime = nowTime.addingTimeInterval(TimeInterval(-self.secondsElapsed))
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

      kickBoardHistory.createHistory(
        userId: userID,
        duration: Int16(self.secondsElapsed),
        startTime: dateFormatter.string(from: startTime),
        type: KickboardType(rawValue: self.riddingKickBoard?.kickboardType?.rawValue ?? "타입 정보가 없습니다.") ?? .kickboard
      )

      self.allKickBoardMarker()
      self.hiddenRiddingView()

      self.locationMove(nowLocation: self.locationManager)
      self.locationManager.stopUpdatingLocation()
      self.mapView.positionMode = .normal
      self.riddingKickBoard = nil
      self.timer = nil

      // 반납완료 되어 대여버튼 활성화 시켜주기
      self.riddingButton.isEnabled = true
      self.riddingButton.backgroundColor = .main
      self.riddingButton.setTitle("대여하기", for: .normal)
    }
    confirm.isEnabled = false
    confirmAction = confirm

    alert.addAction(confirm)
    alert.addAction(UIAlertAction(title: "취소", style: .cancel))

    present(alert, animated: true)
  }
}

// MARK: - SearchBar Delegate

extension MapViewController: UISearchBarDelegate {
  func searchBar(_: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      hiddenCollectionView()
    } else {
      searchData(query: searchText)
    }
  }
}

// MARK: - CollectionViewDataSource

extension MapViewController: UICollectionViewDataSource {
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    places.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard indexPath.item < places.count else {
      print("❌ indexPath out of bounds: \(indexPath.item) / \(places.count)")
      return UICollectionViewCell()
    }

    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: SearchResultCell.identifier,
      for: indexPath
    ) as? SearchResultCell else {
      return UICollectionViewCell()
    }

    cell.configure(with: places[indexPath.item])
    return cell
  }
}

// MARK: - CollectionViewDelegate

extension MapViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    let place = places[indexPath.item]

    // 위경도는 0.0000001 곱해서 실제 GPS 위치로 변환
    if let latValue = Double(place.lat),
       let lngValue = Double(place.lng)
    {
      let lat = latValue * 0.0000001
      let lng = lngValue * 0.0000001

      print("\(place.address)로 이동합니다")
      print("위도: \(lat) 경도: \(lng)")

      let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng), zoomTo: 16)
      mapView.moveCamera(cameraUpdate)
    }
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
    guard let location = locations.last else { return }
    let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude), zoomTo: 16)

    cameraUpdate.animation = .fly
    cameraUpdate.animationDuration = 0.5
    mapView.moveCamera(cameraUpdate)
    mapView.positionMode = .direction
    print("카메라 업데이트: \(cameraUpdate)")
  }
}

// MARK: - Camera Delegate

extension MapViewController: NMFMapViewCameraDelegate {
  // 카메라 이동 됐을때
  func mapView(_: NMFMapView, cameraIsChangingByReason reason: Int) {
    print("카메라 이동: \(reason)")
    hiddenCollectionView()
    locationManager.stopUpdatingLocation()
  }
}

// MARK: - Touch Delegate

extension MapViewController: NMFMapViewTouchDelegate {
  // 지도를 길게 눌렀을때
  func mapView(_: NMFMapView, didLongTapMap latlng: NMGLatLng, point _: CGPoint) {
    print("롱 탭: \(latlng.lat), \(latlng.lng)")
    // 탑승 중일때는 등록 안되게
    if riddingButton.isEnabled == true {
      let addKickBoardVC = KickBoardViewController(latitude: latlng.lat, longitude: latlng.lng)
      addKickBoardVC.delegate = self
      navigationController?.pushViewController(addKickBoardVC, animated: true)
    } else {
      let alert = UIAlertController(
        title: "등록 불가",
        message: "기기를 탑승중입니다. 반납을 진행 후 기기등록 해주세요.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "확인", style: .default))
      present(alert, animated: true)
    }
  }

  // 지도를 짧게 눌렀을때
  func mapView(_: NMFMapView, didTapMap latlng: NMGLatLng, point _: CGPoint) {
    print("숏 탭: \(latlng.lat), \(latlng.lng)")
    hiddenCollectionView()
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
