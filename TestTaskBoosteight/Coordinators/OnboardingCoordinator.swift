//
//  OnboardingCoordinator.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Координатор онбординга: создаёт `OnboardingViewController`, проксирует событие завершения вверх по иерархии.
final class OnboardingCoordinator: Coordinator {
    /// Навигационный контроллер, владеющий стеком экранов и обеспечивающий навигацию внутри онбординга.
    let navigationController: UINavigationController

    /// Замыкание, вызываемое при завершении онбординга. Устанавливается родительским координатором.
    var onFinish: (() -> Void)?

    /// Инициализатор с внедрением навигационного контроллера.
    /// - Parameter navigationController: Контроллер, управляющий стеком экранов онбординга.
    /// Пример:
    /// ```swift
    /// let onboarding = OnboardingCoordinator(navigationController: nav)
    /// ```
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Запускает онбординг: создаёт `OnboardingViewController`, назначает `onContinue` и устанавливает стек навигации.
    /// Пример:
    /// ```swift
    /// onboarding.start()
    /// ```
    func start() {
        let vc = OnboardingViewController()
        vc.onContinue = { [weak self] in
            self?.onFinish?()
        }
        navigationController.setViewControllers([vc], animated: false)
    }
}

