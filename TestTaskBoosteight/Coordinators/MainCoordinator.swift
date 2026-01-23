//
//  MainCoordinator.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit

/// Корневой координатор основного приложения: открывает экраны Медиа и Видео-компрессора.
final class MainCoordinator: Coordinator {
    /// Навигационный контроллер, владеющий стеком экранов.
    let navigationController: UINavigationController

    /// Храним ссылку на дочерний координатор Медиа, чтобы удерживать его в памяти.
    private var mediaCoordinator: MediaCoordinator?
    /// Храним ссылку на дочерний координатор Видео-компрессора, чтобы удерживать его в памяти.
    private var compressorCoordinator: VideoCompressorCoordinator?

    /// Инициализатор с внедрением навигационного контроллера.
    /// - Parameter navigationController: Контроллер, которым управляет координатор.
    /// Пример:
    /// ```swift
    /// let main = MainCoordinator(navigationController: nav)
    /// ```
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    /// Создаёт `MainViewController`, назначает коллбеки открытия экранов и устанавливает контроллер как корневой.
    /// Пример:
    /// ```swift
    /// main.start()
    /// ```
    func start() {
        let vc = MainViewController()
        vc.onOpenMedia = { [weak self] in self?.openMedia() }
        vc.onOpenCompressor = { [weak self] in self?.openCompressor() }
        navigationController.setViewControllers([vc], animated: false)
    }

    /// Создаёт и запускает координатор Медиа-экрана.
    private func openMedia() {
        let coordinator = MediaCoordinator(navigationController: navigationController)
        mediaCoordinator = coordinator
        coordinator.start()
    }

    /// Создаёт и запускает координатор экрана Видео-компрессора.
    private func openCompressor() {
        let coordinator = VideoCompressorCoordinator(navigationController: navigationController)
        compressorCoordinator = coordinator
        coordinator.start()
    }
}

