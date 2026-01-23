//
//  AppDelegate.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Точка входа приложения (iOS): управляет жизненным циклом и конфигурацией сцен.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Вызывается при завершении запуска приложения.
    /// - Parameters:
    ///   - application: Экземпляр приложения.
    ///   - launchOptions: Опции запуска.
    /// - Returns: true, если запуск успешен.
    /// Пример:
    /// ```swift
    /// // Инициализация аналитики/логирования
    /// ```
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    /// Возвращает конфигурацию для новой сцены.
    /// - Parameters:
    ///   - application: Экземпляр приложения.
    ///   - connectingSceneSession: Подключаемая сессия сцены.
    ///   - options: Опции подключения.
    /// - Returns: Объект `UISceneConfiguration`.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Вызывается при удалении сессий сцен: освободите ресурсы, связанные с этими сценами.
    /// - Parameters:
    ///   - application: Экземпляр приложения.
    ///   - sceneSessions: Набор удалённых сессий.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

