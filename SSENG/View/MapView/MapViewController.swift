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
  private let mapView = NMFMapView()

  // 현위치 추적용
  let locationManager = CLLocationManager()

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
    $0.layer.cornerRadius = 8
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
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
  }

  // 킥보드 등록 버튼
  private let addKickBoardButton = UIButton().then {
    $0.setImage(UIImage(systemName: "plus"), for: .normal)
    $0.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium), forImageIn: .normal)
    $0.tintColor = .main
    $0.layer.cornerRadius = 8
    $0.backgroundColor = .clear
    $0.clipsToBounds = true
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()
    setupConstraints()

    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }

  private func setupUI() {
    [mapView, controlStackView, addKickBoardButton].forEach { view.addSubview($0) }
    [reloadButton, dividerView, locationButton].forEach { controlStackView.addArrangedSubview($0) }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
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
      $0.height.equalTo(1) // 얇은 선
    }

    addKickBoardButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(20)
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      $0.size.equalTo(50)
    }
  }
}

// TODO: - 지도 API 받아오지 못 했을 경우 에러처리

// @available(iOS 17.0, *)
// #Preview {
//  MapViewController()
// }
