//
//  SceneDelegate.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Делегат сцены: создаёт окно приложения, настраивает корневой UINavigationController и запускает AppCoordinator.
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    /// Главное окно приложения для данной сцены.
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    /// Точка подключения сцены: создаёт UIWindow, прячет навбар, устанавливает корневой контроллер и стартует AppCoordinator.
    /// - Parameters:
    ///   - scene: Текущая сцена.
    ///   - session: Сессия сцены.
    ///   - connectionOptions: Опции подключения.
    /// Пример:
    /// ```swift
    /// // вызывается системой при создании сцены
    /// ```
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }
        
//        UIView.setAnimationsEnabled(false)

        let window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController()
        nav.navigationBar.isHidden = true

        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window

        let coordinator = AppCoordinator(navigationController: nav)
        self.appCoordinator = coordinator
        coordinator.start()
    }
}

