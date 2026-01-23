//
//  OnboardingViewModel.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 21.01.2026.
//

import Foundation
import RxSwift
import RxCocoa

/// ViewModel онбординга: хранит страницы, управляет текущим индексом и сигналами завершения/перехода.
/// Использует RxSwift/RxCocoa для Input/Output.
final class OnboardingViewModel {

    /// Входные сигналы ViewModel.
    /// - didTapContinue: нажатие кнопки Continue
    /// - didSwipeToIndex: перелистывание на индекс
    /// - didSelectPageIndex: выбор индекса через PageControl
    /// Пример:
    /// ```swift
    /// let input = OnboardingViewModel.Input(
    ///   didTapContinue: continueButton.rx.tap.asSignal(),
    ///   didSwipeToIndex: didSwipeRelay.asSignal(),
    ///   didSelectPageIndex: didSelectPageRelay.asSignal()
    /// )
    /// ```
    struct Input {
        let didTapContinue: Signal<Void>
        let didSwipeToIndex: Signal<Int>
        let didSelectPageIndex: Signal<Int>
    }

    /// Выходные данные ViewModel.
    /// - currentIndex: текущий индекс страницы
    /// - pagesCount: количество страниц
    /// - title: заголовок текущей страницы
    /// - subtitle: подзаголовок текущей страницы
    /// - buttonTitle: текст кнопки
    /// - finish: сигнал завершения онбординга
    /// - goToIndex: сигнал перехода к индексу
    /// Пример:
    /// ```swift
    /// viewModel.output.pagesCount
    ///   .drive(pageControl.rx.pageCount)
    ///   .disposed(by: bag)
    /// ```
    struct Output {
        let currentIndex: Driver<Int>
        let pagesCount: Driver<Int>
        let title: Driver<String>
        let subtitle: Driver<String>
        let buttonTitle: Driver<String>
        let finish: Signal<Void>
        let goToIndex: Signal<Int>
    }

    let output: Output

    // ✅ синхронно доступно VC для сборки pagesVC
    var pagesCountValue: Int { pages.count }

    private let pages: [OnboardingPage]

    private let currentIndexRelay = BehaviorRelay<Int>(value: 0)
    private let finishRelay = PublishRelay<Void>()
    private let goToIndexRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()

    /// Инициализирует ViewModel страницами и настраивает реактивные цепочки для входов/выходов.
    /// - Parameter input: Набор входных сигналов из View.
    /// Пример:
    /// ```swift
    /// let vm = OnboardingViewModel(input: input)
    /// ```
    init(input: Input) {
        self.pages = [
            .init(title: "Clean your Storage",
                  subtitle: "Pick the best & delete the rest",
                  images: ["onb_1"]),
            .init(title: "Detect Similar Photos",
                  subtitle: "Clean similar photos & videos, save your storage space on your phone.",
                  images: ["onb_1", "onb_2_storage"]),
            .init(title: "Video Compressor",
                  subtitle: "Find large videos or media files and compress them to free up storage space",
                  images: ["onb_3"])
        ]

        // 1) сначала формируем outputs (НЕ трогаем self.output до присвоения)
        let currentIndexDriver = currentIndexRelay.asDriver()

        let titleDriver = currentIndexDriver
            .map { [pages] idx in pages[safe: idx]?.title ?? "" }

        let subtitleDriver = currentIndexDriver
            .map { [pages] idx in pages[safe: idx]?.subtitle ?? "" }

        let buttonTitleDriver = Driver.just("Continue")
        let pagesCountDriver = Driver.just(pages.count)

        self.output = Output(
            currentIndex: currentIndexDriver,
            pagesCount: pagesCountDriver,
            title: titleDriver,
            subtitle: subtitleDriver,
            buttonTitle: buttonTitleDriver,
            finish: finishRelay.asSignal(),
            goToIndex: goToIndexRelay.asSignal()
        )

        // 2) теперь подписки на input (после инициализации self.output)
        Signal.merge(input.didSwipeToIndex, input.didSelectPageIndex)
            .emit(onNext: { [weak self] idx in
                self?.setIndex(idx)
            })
            .disposed(by: disposeBag)

        input.didTapContinue
            .emit(onNext: { [weak self] in
                self?.handleContinue()
            })
            .disposed(by: disposeBag)
    }

    /// Возвращает модель страницы по индексу или первую при выходе за пределы.
    /// - Parameter index: Индекс страницы.
    /// - Returns: Модель `OnboardingPage`.
    /// Пример:
    /// ```swift
    /// let page = viewModel.page(at: 0)
    /// ```
    func page(at index: Int) -> OnboardingPage {
        pages[safe: index] ?? pages[0]
    }

    /// Обрабатывает нажатие Continue: вычисляет следующий индекс, эмитит goToIndex или finish при достижении конца.
    private func handleContinue() {
        let idx = currentIndexRelay.value
        let next = idx + 1
        if next < pages.count {
            setIndex(next)
            goToIndexRelay.accept(next)     // ✅ VM решает куда перейти
        } else {
            finishRelay.accept(())
        }
    }

    /// Устанавливает текущий индекс с ограничением в допустимый диапазон.
    /// - Parameter index: Желаемый индекс страницы.
    private func setIndex(_ index: Int) {
        let clamped = max(0, min(index, pages.count - 1))
        currentIndexRelay.accept(clamped)
    }
}

private extension Array {
    /// Безопасный сабскрипт массива: возвращает элемент по индексу или nil, если индекс вне диапазона.
    /// - Parameter index: Индекс элемента.
    /// - Returns: Элемент или nil.
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
