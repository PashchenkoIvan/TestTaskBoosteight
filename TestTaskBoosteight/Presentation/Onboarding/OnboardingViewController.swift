//
//  OnboardingViewController.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// Экран онбординга с горизонтальным `UIPageViewController`, точками `PageControl` и кнопкой `PurpleButton`.
/// Координируется `OnboardingViewModel` через Rx.
/// Пример:
/// ```swift
/// let vc = OnboardingViewController()
/// vc.onContinue = { /* завершить онбординг */ }
/// navigationController.setViewControllers([vc], animated: false)
/// ```
final class OnboardingViewController: UIViewController {

    // MARK: Subviews
    private let pageViewController: UIPageViewController
    private let pageControl = PageControl()
    private let continueButton = PurpleButton("Continue")

    // MARK: Properties
    /// Коллбэк, вызываемый при завершении онбординга (последняя страница → Continue).
    /// Пример:
    /// ```swift
    /// onboardingVC.onContinue = { coordinator.onFinish?() }
    /// ```
    public var onContinue: (() -> Void)?
    private let disposeBag = DisposeBag()

    // Inputs relays
    private let didSwipeRelay = PublishRelay<Int>()
    private let didSelectPageRelay = PublishRelay<Int>()

    private let viewModel: OnboardingViewModel
    private var pagesVC: [UIViewController] = []
    private var currentShownIndex: Int = 0

    /// Инициализирует контроллер, создаёт входы `OnboardingViewModel` из Rx-событий и настраивает VM.
    /// Входы:
    ///  - didTapContinue: сигнал нажатия на кнопку Continue
    ///  - didSwipeToIndex: сигнал индекса страницы после свайпа
    ///  - didSelectPageIndex: сигнал индекса выбранной точки PageControl
    /// Пример:
    /// ```swift
    /// let vc = OnboardingViewController()
    /// ```
    init() {
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)

        let input = OnboardingViewModel.Input(
            didTapContinue: continueButton.rx.tap.asSignal(),
            didSwipeToIndex: didSwipeRelay.asSignal(),
            didSelectPageIndex: didSelectPageRelay.asSignal()
        )
        self.viewModel = OnboardingViewModel(input: input)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Системный вызов: сборка UI, настройка PageViewController, создание страниц и биндинги с ViewModel.
    /// Пример: вызывается системой при загрузке экрана.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageVC()
        buildPages()
        bindViewModel()
    }

    /// Биндит выходы ViewModel к UI: количество страниц, текущий индекс, завершение онбординга, переход к индексу.
    /// Пример:
    /// ```swift
    /// viewModel.output.pagesCount.drive(pageControl.rx.pageCount)
    /// ```
    private func bindViewModel() {
        viewModel.output.pagesCount
            .drive(pageControl.rx.pageCount)
            .disposed(by: disposeBag)

        viewModel.output.currentIndex
            .distinctUntilChanged()
            .drive(pageControl.rx.currentPage)
            .disposed(by: disposeBag)

        viewModel.output.finish
            .emit(onNext: { [weak self] in
                self?.onContinue?()
            })
            .disposed(by: disposeBag)

        viewModel.output.goToIndex
            .emit(onNext: { [weak self] index in
                self?.setPage(index, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

private extension OnboardingViewController {

    /// Настраивает `UIPageViewController` (dataSource и delegate).
    /// Вызывается один раз при сборке экрана.
    func setupPageVC() {
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }

    /// Создаёт массив `OnboardingPageViewController` на основе данных ViewModel и устанавливает первую страницу.
    /// Пример: вызывается из `viewDidLoad()`.
    func buildPages() {
        let count = viewModel.pagesCountValue
        pagesVC = (0..<count).map { OnboardingPageViewController(page: viewModel.page(at: $0)) }

        if let first = pagesVC.first {
            pageViewController.setViewControllers([first], direction: .forward, animated: false)
            currentShownIndex = 0
        }
    }

    /// Программно устанавливает страницу по индексу с учётом направления анимации.
    /// - Parameters:
    ///   - index: Целевой индекс страницы.
    ///   - animated: Флаг анимированного перехода.
    /// Пример:
    /// ```swift
    /// setPage(2, animated: true)
    /// ```
    func setPage(_ index: Int, animated: Bool) {
        guard pagesVC.indices.contains(index) else { return }
        let direction: UIPageViewController.NavigationDirection = (index >= currentShownIndex) ? .forward : .reverse
        currentShownIndex = index
        pageViewController.setViewControllers([pagesVC[index]], direction: direction, animated: animated)
    }

    /// Собирает и раскладывает subviews, настраивает констрейнты с SnapKit.
    /// Использует `Size.getWidth`/`getHeight` для адаптивных отступов/высот.
    func setupUI() {
        view.backgroundColor = .systemBackground

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageControl)
        view.addSubview(continueButton)

        // констрейнты — подгони под дизайн
        pageViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(88)
            make.leading.trailing.equalToSuperview().inset(34)
            make.bottom.equalTo(pageControl.snp.top).offset(-16)
        }

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(continueButton.snp.top).offset(-16)
        }

        continueButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(Size.getWidth(16))
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(Size.getHeight(16))
            make.height.equalTo(60)
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    /// Возвращает предыдущий контроллер страницы.
    /// Пример: системный вызов при свайпе влево.
    func pageViewController(_ pvc: UIPageViewController,
                            viewControllerBefore vc: UIViewController) -> UIViewController? {
        guard let idx = pagesVC.firstIndex(of: vc), idx > 0 else { return nil }
        return pagesVC[idx - 1]
    }

    /// Возвращает следующий контроллер страницы.
    /// Пример: системный вызов при свайпе вправо.
    func pageViewController(_ pvc: UIPageViewController,
                            viewControllerAfter vc: UIViewController) -> UIViewController? {
        guard let idx = pagesVC.firstIndex(of: vc), idx + 1 < pagesVC.count else { return nil }
        return pagesVC[idx + 1]
    }

    /// Вызывается после завершения анимации перелистывания; обновляет текущий индекс и эмитит его во вход VM.
    func pageViewController(_ pvc: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = pvc.viewControllers?.first,
              let idx = pagesVC.firstIndex(of: current) else { return }

        currentShownIndex = idx
        didSwipeRelay.accept(idx)
    }
}

