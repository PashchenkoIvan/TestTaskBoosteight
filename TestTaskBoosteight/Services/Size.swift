//
//  AdaptiveSizeService.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 23.01.2026.
//

import UIKit

/// Сервис адаптивных размеров.
/// Масштабирует значения из дизайн-макета под текущие размеры экрана.
///
/// Базовые значения соответствуют iPhone 12/13/14 (390x844 pt).
/// Пример использования:
/// ```swift
/// let inset = Size.getWidth(16)
/// let height = Size.getHeight(60)
/// someView.snp.makeConstraints { make in
///     make.left.right.equalToSuperview().inset(inset)
///     make.height.equalTo(height)
/// }
/// ```
final class Size {
    /// Базовая ширина дизайн-макета (в поинтах)
    static let designScreenWidth: CGFloat = 390

    /// Базовая высота дизайн-макета (в поинтах)
    static let designScreenHeight: CGFloat = 844

    /// Текущий размер экрана в поинтах (не в пикселях)
    private static var screenSize: CGSize { UIScreen.main.bounds.size }

    /// Масштаб по ширине относительно дизайна
    private static var widthScale: CGFloat { screenSize.width / designScreenWidth }

    /// Масштаб по высоте относительно дизайна
    private static var heightScale: CGFloat { screenSize.height / designScreenHeight }

    /// Масштабирует значение, заданное для дизайна (390), под текущую ширину экрана.
    /// - Parameter value: Значение из дизайн-макета в поинтах (например, 16).
    /// - Returns: Масштабированное значение под текущую ширину экрана.
    ///
    /// Пример использования:
    /// ```swift
    /// let horizontalInset = Size.getWidth(16)
    /// view.snp.makeConstraints { make in
    ///     make.left.right.equalToSuperview().inset(horizontalInset)
    /// }
    /// ```
    static func getWidth(_ value: CGFloat) -> CGFloat {
        value * widthScale
    }

    /// Масштабирует значение, заданное для дизайна (844), под текущую высоту экрана.
    /// - Parameter value: Значение из дизайн-макета в поинтах (например, 60).
    /// - Returns: Масштабированное значение под текущую высоту экрана.
    ///
    /// Пример использования:
    /// ```swift
    /// let buttonHeight = Size.getHeight(60)
    /// button.snp.makeConstraints { make in
    ///     make.height.equalTo(buttonHeight)
    /// }
    /// ```
    static func getHeight(_ value: CGFloat) -> CGFloat {
        value * heightScale
    }

    /// Универсальное масштабирование одним коэффициентом.
    /// Часто используют минимальный из коэффициентов, чтобы элементы не "разъезжались".
    /// - Parameter value: Значение из дизайн-макета в поинтах.
    /// - Returns: Масштабированное значение, умноженное на `min(widthScale, heightScale)`.
    ///
    /// Пример использования:
    /// ```swift
    /// let cornerRadius = Size.get(12)
    /// view.layer.cornerRadius = cornerRadius
    /// ```
    static func get(_ value: CGFloat) -> CGFloat {
        value * min(widthScale, heightScale)
    }
}
