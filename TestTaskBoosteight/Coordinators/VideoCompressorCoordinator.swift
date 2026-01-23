//
//  VideoCompressorCoordinator.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Координатор экрана видео-компрессора: управляет навигацией в соответствующем разделе.
final class VideoCompressorCoordinator: Coordinator {
    /// Навигационный контроллер, владеющий стеком экранов
    let navigationController: UINavigationController

    /// Инициализатор с внедрением навигационного контроллера.
    /// - Parameter navigationController: Контроллер навигации для управления стеком.
    /// Пример:
    /// ```swift
    /// let compressor = VideoCompressorCoordinator(navigationController: nav)
    /// ```
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Запускает раздел: пушит плейсхолдер-контроллер с заголовком "Video Compressor".
    /// Пример:
    /// ```swift
    /// compressor.start()
    /// ```
    func start() {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Video Compressor"
        navigationController.pushViewController(vc, animated: true)
    }
}

