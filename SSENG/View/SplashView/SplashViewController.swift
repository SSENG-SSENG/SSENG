//
//  SplashViewController.swift
//  SSENG
//
//  Created by 서광용 on 7/21/25.
//

import SnapKit
import Then
import UIKit

class SplashViewController: UIViewController {
  private let logoImageView = UIImageView().then {
    $0.image = UIImage(named: "Logo")
    $0.contentMode = .scaleAspectFit
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    view.addSubview(logoImageView)
    logoImageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(150)
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self.moveToNextScreen()
    }
  }

  private func moveToNextScreen() {
    let loggedUserID = UserDefaults.standard.string(forKey: "loggedUserID")
    let isAutoLogin = UserDefaults.standard.bool(forKey: "isAutoLogin")

    let nextVC: UIViewController = (isAutoLogin && loggedUserID != nil) ? MapViewController() : LoginViewController()

    let nav = UINavigationController(rootViewController: nextVC)
    guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
    sceneDelegate.window?.rootViewController = nav
  }
}
