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

    let rootVC: UIViewController
    let loggedUserID = UserDefaults.standard.string(forKey: "loggedUserID")
    let isAutoLogin = UserDefaults.standard.bool(forKey: "isAutoLogin")

    if isAutoLogin == true && loggedUserID != nil {
      rootVC = MapViewController()
    } else {
      rootVC = LoginViewController()
    }

    let navController = UINavigationController(rootViewController: rootVC)

    window?.rootViewController = navController
    window?.makeKeyAndVisible()
  }

  func sceneDidDisconnect(_: UIScene) {}

  func sceneDidBecomeActive(_: UIScene) {}

  func sceneWillResignActive(_: UIScene) {}

  func sceneWillEnterForeground(_: UIScene) {}

  func sceneDidEnterBackground(_: UIScene) {
    (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
  }
}
