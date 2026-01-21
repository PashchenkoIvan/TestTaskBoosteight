//
//  SceneDelegate.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController()
        nav.navigationBar.isHidden = true

        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window

        let coordinator = AppCoordinator(navigationController: nav)
        coordinator.start()
    }
}
