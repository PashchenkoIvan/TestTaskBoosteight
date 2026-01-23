//
//  OnboardingPageViewController.swift
//  TestTaskBoosteight
//
//  Created by Пащенко Иван on 22.01.2026.
//

import UIKit
import SnapKit

/// Отдельная страница онбординга: одна или две картинки, заголовок и подзаголовок.
/// Пример:
/// ```swift
/// let page = OnboardingPage(title: "Title", subtitle: "Sub", images: ["img1", "img2"]) // ваш тип модели
/// let vc = OnboardingPageViewController(page: page)
/// ```
final class OnboardingPageViewController: UIViewController {

    // MARK: - UI
    private let imageView = UIImageView()
    private let secondaryImageView = UIImageView() // если на некоторых страницах 2 картинки
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Data
    private let page: OnboardingPage

    // MARK: - Init
    /// Инициализирует страницу онбординга моделью `OnboardingPage`.
    /// - Parameter page: Модель страницы (title, subtitle, images).
    /// Пример:
    /// ```swift
    /// let vc = OnboardingPageViewController(page: page)
    /// ```
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    /// Системный вызов: собирает UI и применяет данные модели к элементам интерфейса.
    /// Пример: вызывается системой при загрузке контроллера.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        apply(page: page)
    }
}

// MARK: - Private
private extension OnboardingPageViewController {

    /// Собирает и настраивает иерархию вью: imageView, secondaryImageView, titleLabel, subtitleLabel.
    /// Применяет констрейнты с учётом адаптивных размеров `Size`.
    func setupUI() {
        view.backgroundColor = .clear

        // Images
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        secondaryImageView.contentMode = .scaleAspectFit
        secondaryImageView.clipsToBounds = true
        secondaryImageView.isHidden = true

        // Labels
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center

        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel

        // Layout
        view.addSubview(imageView)
        view.addSubview(secondaryImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        imageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.width.equalTo(246)
        }

        secondaryImageView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(Size.getHeight(-40))
            make.centerX.equalToSuperview()
            make.height.equalTo(Size.getHeight(80))
            make.width.equalTo(Size.getWidth(284))
        }
        
        if secondaryImageView.isHidden {
            titleLabel.snp.updateConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(Size.getHeight(54))
                make.horizontalEdges.equalToSuperview().inset(Size.getWidth(24))
            }
        } else {
            titleLabel.snp.updateConstraints { make in
                make.top.greaterThanOrEqualTo(secondaryImageView.snp.bottom).offset(Size.getHeight(24))
                make.horizontalEdges.equalToSuperview().inset(Size.getWidth(24))
            }
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Size.getHeight(8))
            make.horizontalEdges.equalToSuperview().inset(Size.getWidth(24))
            make.bottom.equalToSuperview()
        }
    }

    /// Применяет данные модели к UI: устанавливает изображения и тексты, скрывает вторую картинку при отсутствии.
    /// - Parameter page: Модель страницы для отображения.
    /// Пример:
    /// ```swift
    /// apply(page: somePage)
    /// ```
    func apply(page: OnboardingPage) {
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle

        // Первая картинка
        if let first = page.images.first {
            imageView.image = UIImage(named: first)
        } else {
            imageView.image = nil
        }

        // Вторая (если есть)
        if page.images.count > 1 {
            secondaryImageView.isHidden = false
            secondaryImageView.image = UIImage(named: page.images[1])
        } else {
            secondaryImageView.isHidden = true
            secondaryImageView.image = nil
        }
    }
}

