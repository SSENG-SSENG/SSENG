//
//  SceneDelegate.swift
//  SSENG
//
//  Created by 이태윤 on 7/15/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: LoginViewController()) // 시작 뷰컨트롤러 지정
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_: UIScene) {}

  func sceneDidBecomeActive(_: UIScene) {}

  func sceneWillResignActive(_: UIScene) {}

  func sceneWillEnterForeground(_: UIScene) {
    // 앱이 포그라운드로 진입할 때 알림을 보냄
    NotificationCenter.default.post(name: .appDidEnterForeground, object: nil)
  }

  func sceneDidEnterBackground(_: UIScene) {
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }
}
