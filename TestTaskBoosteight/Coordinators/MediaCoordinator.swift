//
//  MediaCoordinator.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Координатор медиа-экрана: отвечает за навигацию в разделе медиа.
/// Этот координатор отвечает за стек медиа-экрана.
/// В данный момент он пушит простой плейсхолдер.
final class MediaCoordinator: Coordinator {
    /// Navigation controller для управления стеком переходов.
    let navigationController: UINavigationController

    /// Инициализатор с внедрением навигационного контроллера.
    /// - Parameter navigationController: Контроллер навигации для управления стеком.
    /// Пример:
    /// ```swift
    /// let media = MediaCoordinator(navigationController: nav)
    /// ```
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Запускает раздел медиа: пушит плейсхолдер-контроллер с заголовком "Media".
    /// Пример:
    /// ```swift
    /// media.start()
    /// ```
    func start() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Media"
        navigationController.pushViewController(vc, animated: true)
    }
}

