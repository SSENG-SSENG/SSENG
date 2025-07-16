//
//  KickBoardViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import NMapsMap
import SnapKit
import Then
import UIKit

class KickBoardViewController: UIViewController {
  private let latitude: Double
  private let longitude: Double

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
    print("위도 : \(latitude), 경도 : \(longitude)")

    let addKickBoardView = NMFNaverMapView()
    view.addSubview(addKickBoardView)
    addKickBoardView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    let marker = NMFMarker()
    marker.position = NMGLatLng(lat: latitude, lng: longitude)
    marker.mapView = addKickBoardView.mapView
  }
}
