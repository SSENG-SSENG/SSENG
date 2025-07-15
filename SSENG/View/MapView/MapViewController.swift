//
//  MapViewController.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//
import MapKit
import NMapsMap
import SnapKit
import Then
import UIKit

class MapViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let mapView = NMFMapView(frame: view.frame)
    view.addSubview(mapView)
  }
}

// TODO: - 지도 API 받아오지 못 했을 경우 에러처리

@available(iOS 17.0, *)
#Preview {
  MapViewController()
}
