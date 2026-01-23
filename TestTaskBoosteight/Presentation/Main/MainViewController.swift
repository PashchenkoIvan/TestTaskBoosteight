//
//  MainViewController.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

/// Стартовый экран с двумя кнопками навигации: к медиа и к видео-компрессору.
/// Пример:
/// ```swift
/// let vc = MainViewController()
/// vc.onOpenMedia = { /* open media */ }
/// vc.onOpenCompressor = { /* open compressor */ }
/// ```
final class MainViewController: UIViewController {

    /// Коллбэк, вызываемый при нажатии кнопки "Open Media".
    /// Пример:
    /// ```swift
    /// mainVC.onOpenMedia = { coordinator.openMedia() }
    /// ```
    var onOpenMedia: (() -> Void)?
    /// Коллбэк, вызываемый при нажатии кнопки "Open Video Compressor".
    /// Пример:
    /// ```swift
    /// mainVC.onOpenCompressor = { coordinator.openCompressor() }
    /// ```
    var onOpenCompressor: (() -> Void)?

    /// Системный вызов: настраивает фон, создаёт кнопки и размещает их в вертикальном стеке по центру экрана.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let mediaBtn = UIButton(type: .system)
        mediaBtn.setTitle("Open Media", for: .normal)
        mediaBtn.addTarget(self, action: #selector(openMedia), for: .touchUpInside)

        let compBtn = UIButton(type: .system)
        compBtn.setTitle("Open Video Compressor", for: .normal)
        compBtn.addTarget(self, action: #selector(openCompressor), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [mediaBtn, compBtn])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// Системный вызов: демонстрационный отложенный запрос доступа к Фото через 2 секунды.
    /// - Parameter animated: Признак анимированного появления.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.requestPhotosAccessIfNeeded()
        }
    }

    /// Проверяет текущий статус доступа к фотобиблиотеке и, если статус `.notDetermined`, запрашивает разрешение.
    /// Пример:
    /// ```swift
    /// // Обычно вызывается из viewDidAppear
    /// ```
    private func requestPhotosAccessIfNeeded() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .notDetermined else { return }

        PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in }
    }

    /// Обработчик нажатия кнопки "Open Media": вызывает коллбэк `onOpenMedia`.
    @objc private func openMedia() { onOpenMedia?() }
    /// Обработчик нажатия кнопки "Open Video Compressor": вызывает коллбэк `onOpenCompressor`.
    @objc private func openCompressor() { onOpenCompressor?() }
}

