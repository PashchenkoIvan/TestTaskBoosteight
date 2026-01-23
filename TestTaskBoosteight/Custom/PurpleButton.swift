//
//  PurpleButton.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 23.01.2026.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// Кастомная фиолетовая кнопка на основе UIView с анимацией нажатия и Rx-событием `tap`.
/// Пример использования:
/// ```swift
/// let button = PurpleButton("Continue")
/// let bag = DisposeBag()
/// button.rx.tap
///     .bind(onNext: { print("Tapped") })
///     .disposed(by: bag)
/// ```
final class PurpleButton: UIView {

    private let label = UILabel()

    fileprivate let tapRelay = PublishRelay<Void>()

    /// Создаёт кнопку со строкой `text`, настраивает внешний вид и добавляет жест нажатия.
    /// - Parameter text: Текст, отображаемый на кнопке.
    /// Пример:
    /// ```swift
    /// let btn = PurpleButton("Оплатить")
    /// ```
    init(_ text: String) {
        super.init(frame: .zero)

        backgroundColor = UIColor(named: "appPurple")
        layer.cornerRadius = 16
        clipsToBounds = true
        isUserInteractionEnabled = true

        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center

        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Обновляет текст кнопки.
    /// - Parameter text: Новый текст для отображения.
    /// Пример:
    /// ```swift
    /// button.setTitle("Далее")
    /// ```
    func setTitle(_ text: String) {
        label.text = text
    }

    /// Обработчик нажатия: проигрывает короткую анимацию и эмитит событие в `tapRelay`.
    /// Вызывается автоматически распознавателем жестов `UITapGestureRecognizer`.
    /// Пример:
    /// ```swift
    /// // вызывать вручную не требуется
    /// ```
    @objc private func handleTap() {
        UIView.animate(withDuration: 0.08, animations: {
            self.alpha = 0.7
        }, completion: { _ in
            UIView.animate(withDuration: 0.08) { self.alpha = 1.0 }
        })

        tapRelay.accept(())
    }
}

extension Reactive where Base: PurpleButton {
    /// RxCocoa-обёртка события нажатия на `PurpleButton`.
    /// Пример:
    /// ```swift
    /// let bag = DisposeBag()
    /// button.rx.tap
    ///     .bind(onNext: { /* обработать нажатие */ })
    ///     .disposed(by: bag)
    /// ```
    var tap: ControlEvent<Void> {
        ControlEvent(events: base.tapRelay.asObservable())
    }
}
