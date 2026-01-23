import UIKit
import RxSwift
import RxCocoa

/// Индикатор страниц на основе UIStackView: набор точек, одна из которых выделена.
/// Поддерживает Rx-биндинги для количества страниц, текущего индекса и выбора.
/// Пример:
/// ```swift
/// let pc = PageControl()
/// pc.setPageCount(3)
/// pc.setCurrentPage(1)
/// ```
final class PageControl: UIStackView {

    // MARK: - Private
    private var pointViews: [PointView] = []
    private var pointsDisposeBag = DisposeBag()

    private var pageCount: Int = 0
    private var currentPage: Int = 0

    // MARK: - Output (если нужны тапы)
    fileprivate let didSelectPageRelay = PublishRelay<Int>()
    var didSelectPage: Observable<Int> { didSelectPageRelay.asObservable() }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureStack()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API
    /// Устанавливает количество точек и перестраивает индикатор.
    /// - Parameter count: Количество страниц (>= 0).
    /// Пример:
    /// ```swift
    /// pageControl.setPageCount(5)
    /// ```
    func setPageCount(_ count: Int) {
        let newCount = max(0, count)
        guard newCount != pageCount else { return }

        pageCount = newCount
        rebuildPoints()

        // на всякий случай нормализуем currentPage
        let clamped = max(0, min(currentPage, max(0, pageCount - 1)))
        setCurrentPage(clamped, animated: false)
    }

    /// Устанавливает текущую страницу.
    /// - Parameters:
    ///   - index: Индекс текущей страницы.
    ///   - animated: Анимировать ли изменение.
    /// Пример:
    /// ```swift
    /// pageControl.setCurrentPage(2, animated: true)
    /// ```
    func setCurrentPage(_ index: Int, animated: Bool = true) {
        guard pageCount > 0 else { return }

        let clamped = max(0, min(index, pageCount - 1))
        guard clamped != currentPage || pointViews.isEmpty == false else { return }

        currentPage = clamped

        let updates = {
            for (i, v) in self.pointViews.enumerated() {
                v.setStatus(i == clamped ? .selected : .normal)
            }
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) { updates() }
        } else {
            updates()
        }
    }
}

// MARK: - Private
private extension PageControl {

    /// Первичная конфигурация стека: ось, выравнивание, распределение, отступы.
    func configureStack() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 4
    }

    /// Перестраивает набор точек согласно `pageCount`, сбрасывает подписки и создаёт новые элементы.
    func rebuildPoints() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        pointViews.removeAll()
        pointsDisposeBag = DisposeBag() // сброс подписок на тапы

        guard pageCount > 0 else { return }

        for i in 0..<pageCount {
            let v = PointView()
            v.isUserInteractionEnabled = false
            addArrangedSubview(v)
            pointViews.append(v)

            // Опционально: тапы по точке -> наружу индекс
            v.rx.tap
                .map { i }
                .bind(to: didSelectPageRelay)
                .disposed(by: pointsDisposeBag)
        }
    }
}

// MARK: - PointView
private final class PointView: UIView {

    /// Состояние точки индикатора: обычная или выделенная.
    enum Status { case normal, selected }

    private let height: CGFloat = 8
    private let normalWidth: CGFloat = 8
    private let selectedWidth: CGFloat = 16

    private var widthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        widthConstraint = widthAnchor.constraint(equalToConstant: normalWidth)
        NSLayoutConstraint.activate([
            widthConstraint,
            heightAnchor.constraint(equalToConstant: height)
        ])

        layer.cornerRadius = height / 2
        clipsToBounds = true
        isUserInteractionEnabled = true

        setStatus(.normal)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Применяет визуальное состояние точки.
    /// - Parameter status: Новое состояние (`.normal` или `.selected`).
    /// Пример:
    /// ```swift
    /// point.setStatus(.selected)
    /// ```
    func setStatus(_ status: Status) {
        widthConstraint.constant = (status == .selected) ? selectedWidth : normalWidth
        backgroundColor = (status == .selected)
            ? UIColor(named: "appPurple")
            : UIColor(named: "appGray")
    }
}

// MARK: - Rx helpers
private extension Reactive where Base: UIView {
    /// Rx-обёртка для тапа по любой UIView: создаёт UITapGestureRecognizer и мапит событие в Void.
    /// Пример:
    /// ```swift
    /// someView.rx.tap
    ///   .bind(onNext: { print("tapped") })
    ///   .disposed(by: bag)
    /// ```
    var tap: ControlEvent<Void> {
        let gesture = UITapGestureRecognizer()
        base.addGestureRecognizer(gesture)
        return ControlEvent(events: gesture.rx.event.map { _ in () })
    }
}

extension Reactive where Base: PageControl {

    /// Биндинг количества страниц.
    /// Пример:
    /// ```swift
    /// viewModel.output.pagesCount
    ///   .drive(pageControl.rx.pageCount)
    ///   .disposed(by: bag)
    /// ```
    var pageCount: Binder<Int> {
        Binder(base) { control, count in
            control.setPageCount(count)
        }
    }

    /// Биндинг текущей страницы.
    /// Пример:
    /// ```swift
    /// viewModel.output.currentIndex
    ///   .drive(pageControl.rx.currentPage)
    ///   .disposed(by: bag)
    /// ```
    var currentPage: Binder<Int> {
        Binder(base) { control, page in
            control.setCurrentPage(page, animated: true)
        }
    }

    /// Событие выбора точки пользователем (если включено взаимодействие).
    /// Пример:
    /// ```swift
    /// pageControl.rx.didSelectPage
    ///   .bind(onNext: { index in /* обновить VM */ })
    ///   .disposed(by: bag)
    /// ```
    var didSelectPage: ControlEvent<Int> {
        ControlEvent(events: base.didSelectPage)
    }
}
