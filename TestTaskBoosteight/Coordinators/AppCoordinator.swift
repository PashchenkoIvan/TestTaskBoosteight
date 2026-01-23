//
//  AppCoordinator.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Базовый контракт координатора: содержит `navigationController` и точку входа `start()` для запуска флоу.
/// Пример:
/// ```swift
/// final class FeatureCoordinator: Coordinator {
///     let navigationController: UINavigationController
///     init(navigationController: UINavigationController) { self.navigationController = navigationController }
///     func start() { /* показать первый экран */ }
/// }
/// ```
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

/// Корневой координатор приложения: решает, показывать онбординг или основной флоу, и управляет переключением между ними.
final class AppCoordinator: Coordinator {
    /// Навигационный контроллер, используемый для управления стеком экранов.
    let navigationController: UINavigationController

    /// Хранение активного дочернего координатора, чтобы удерживать его в памяти.
    private var child: Coordinator?

    /// Инициализирует координатор с внедрением `UINavigationController`.
    /// - Parameter navigationController: Навигационный контроллер, которым будет управлять координатор.
    /// Пример:
    /// ```swift
    /// let coordinator = AppCoordinator(navigationController: nav)
    /// ```
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Точка входа: проверяет флаг `didFinishOnboarding` и запускает онбординг или основной флоу.
    /// Пример:
    /// ```swift
    /// appCoordinator.start()
    /// ```
    func start() {
        if UserDefaults.standard.bool(forKey: AppFlags.didFinishOnboarding) {
            showMain()
        } else {
            showOnboarding()
        }
    }

    /// Создаёт и запускает онбординг, устанавливает `onFinish`, сохраняет флаг в `UserDefaults`, затем показывает основной флоу.
    private func showOnboarding() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController)
        coordinator.onFinish = { [weak self] in
            UserDefaults.standard.set(true, forKey: AppFlags.didFinishOnboarding)
            self?.showMain()
        }
        child = coordinator
        coordinator.start()
    }

    /// Создаёт и запускает основной координатор приложения.
    private func showMain() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        child = coordinator
        coordinator.start()
    }
}

