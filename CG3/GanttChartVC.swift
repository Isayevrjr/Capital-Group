import UIKit

class GanttChartViewController: UIViewController {
    var project: Project!
    
    private let scrollView = UIScrollView()
    private let timelineContainer = UIView()
    private let timelineView = UIView()
    private let eventsStack = UIStackView()
    private let ganttBarsView = UIView()
    private let currentDateLine = UIView()
    private let calendar = Calendar.current
    private let dayWidth: CGFloat = 4
    private var baseDate: Date!
    private let rowHeight: CGFloat = 60
    
    // Форматтеры
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupBaseDate()
        setupViews()
        createTimeline()
        createEvents()
        createGanttBars()
        setupCurrentDateLine()
        setupNavigationBarForEditing()
    }

    private func setupBaseDate() {
        baseDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))!
    }

    private func setupViews() {
        scrollView.contentSize = CGSize(width: 2000, height: 800)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Контейнер для временной шкалы
        scrollView.addSubview(timelineContainer)
        timelineContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            timelineContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            timelineContainer.widthAnchor.constraint(equalToConstant: 2000),
            timelineContainer.heightAnchor.constraint(equalToConstant: 80) // Увеличили высоту
        ])
        
        // Временная шкала
        timelineView.backgroundColor = .systemGray5
        timelineContainer.addSubview(timelineView)
        
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineView.bottomAnchor.constraint(equalTo: timelineContainer.bottomAnchor),
            timelineView.leadingAnchor.constraint(equalTo: timelineContainer.leadingAnchor),
            timelineView.trailingAnchor.constraint(equalTo: timelineContainer.trailingAnchor),
            timelineView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Стек мероприятий
        eventsStack.axis = .vertical
        scrollView.addSubview(eventsStack)
        
        eventsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventsStack.topAnchor.constraint(equalTo: timelineContainer.bottomAnchor, constant: 16),
            eventsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            eventsStack.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        // Область диаграммы
        scrollView.addSubview(ganttBarsView)
        ganttBarsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ganttBarsView.topAnchor.constraint(equalTo: timelineContainer.bottomAnchor, constant: 16),
            ganttBarsView.leadingAnchor.constraint(equalTo: eventsStack.trailingAnchor, constant: 16),
            ganttBarsView.heightAnchor.constraint(equalToConstant: 500),
            ganttBarsView.widthAnchor.constraint(equalToConstant: 2000),
            ganttBarsView.heightAnchor.constraint(equalToConstant: CGFloat(project.events.count) * rowHeight)
        ])
    }

    private func createTimeline() {
        var currentDate = baseDate!
        let endDate = calendar.date(byAdding: .year, value: 2, to: baseDate)!
        var currentX: CGFloat = 0
        var lastYear: Int?
        
        while currentDate <= endDate {
            let components = calendar.dateComponents([.year, .month, .day], from: currentDate)
            
            // Добавляем год при изменении
            if components.year != lastYear {
                let yearLabel = UILabel()
                yearLabel.text = yearFormatter.string(from: currentDate)
                yearLabel.font = .systemFont(ofSize: 14, weight: .bold)
                yearLabel.frame = CGRect(
                    x: currentX,
                    y: 10,
                    width: 100,
                    height: 20
                )
                timelineContainer.addSubview(yearLabel)
                lastYear = components.year
            }
            
            // Отображаем первое число месяца
            if components.day == 1 {
                let monthLabel = UILabel()
                monthLabel.text = monthFormatter.string(from: currentDate)
                monthLabel.font = .systemFont(ofSize: 10)
                monthLabel.frame = CGRect(
                    x: currentX,
                    y: 50, // Смещаем ниже года
                    width: 60,
                    height: 20
                )
                timelineContainer.addSubview(monthLabel)
                
                // Вертикальная линия
                let line = UIView()
                line.backgroundColor = .systemGray3
                line.frame = CGRect(
                    x: currentX,
                    y: 40,
                    width: 1,
                    height: 40
                )
                timelineContainer.addSubview(line)
                
                currentX += dayWidth * CGFloat(daysInMonth(date: currentDate))
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }

    private func createEvents() {
        project.events.enumerated().forEach { index, event in
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 4
            stack.frame = CGRect(
                           x: 0,
                           y: CGFloat(index) * rowHeight, // Используем новую высоту
                           width: 200,
                           height: rowHeight
                       )
            
            let titleLabel = UILabel()
            titleLabel.text = event.title
            titleLabel.font = .systemFont(ofSize: 14)
            
            let progressLabel = UILabel()
            progressLabel.text = "\(Int(event.progress * 100))%"
            progressLabel.font = .systemFont(ofSize: 12)
            progressLabel.textColor = .systemBlue
            
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(progressLabel)
            
            stack.frame = CGRect(x: 0, y: CGFloat(index * 60), width: 200, height: 50)
            eventsStack.addArrangedSubview(stack)
        }
    }

    private func createGanttBars() {
        let rowHeight: CGFloat = 60 // Высота строки
        let barHeight: CGFloat = 20 // Высота полосы
        let verticalPadding = (rowHeight - barHeight) / 2 // Отступ сверху и снизу
        
        project.events.enumerated().forEach { index, event in
            // Рассчитываем позицию для текущей строки
            let yPosition = CGFloat(index) * rowHeight + verticalPadding
            
            // 1. Создаем фоновую полосу (план)
            let planBar = UIView()
            planBar.backgroundColor = .systemGray5
            planBar.layer.cornerRadius = 4
            
            let startDays = daysFromBase(date: event.startDate)
            let durationDays = calendar.dateComponents([.day], from: event.startDate, to: event.endDate).day!
            
            planBar.frame = CGRect(
                x: CGFloat(startDays) * dayWidth,
                y: yPosition,
                width: CGFloat(durationDays) * dayWidth,
                height: barHeight
            )
            ganttBarsView.addSubview(planBar)
            
            // 2. Создаем полосу прогресса
            let progressBar = UIView()
            progressBar.backgroundColor = .systemBlue
            progressBar.layer.cornerRadius = 4
            
            let progressWidth = CGFloat(durationDays) * dayWidth * CGFloat(event.progress)
            progressBar.frame = CGRect(
                x: CGFloat(startDays) * dayWidth,
                y: yPosition,
                width: progressWidth,
                height: barHeight
            )
            ganttBarsView.addSubview(progressBar)
            
            // 3. Добавляем даты справа от полосы
            let datesLabel = UILabel()
            datesLabel.text = "\(dateFormatter().string(from: event.startDate))-\(dateFormatter().string(from: event.endDate))"
            datesLabel.font = .systemFont(ofSize: 10)
            datesLabel.textColor = .darkGray
            
            // Позиционируем метку дат
            let datesLabelWidth: CGFloat = 120
            let datesLabelX = planBar.frame.maxX + 8 // Отступ 8pt от полосы
            datesLabel.frame = CGRect(
                x: datesLabelX,
                y: yPosition - 2, // Корректировка для вертикального центрирования
                width: datesLabelWidth,
                height: barHeight + 4
            )
            ganttBarsView.addSubview(datesLabel)
            
            // 4. Добавляем вертикальную линию разделения
            let separator = UIView()
            separator.backgroundColor = .systemGray4
            separator.frame = CGRect(
                x: 0,
                y: CGFloat(index + 1) * rowHeight - 1,
                width: ganttBarsView.frame.width,
                height: 1
            )
            ganttBarsView.addSubview(separator)
        }
    }
    // Вспомогательные методы
    
    private func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }
    
    private func daysFromBase(date: Date) -> Int {
        calendar.dateComponents([.day], from: baseDate, to: date).day ?? 0
    }
    
    private func daysInMonth(date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    private func setupCurrentDateLine() {
        let today = Date()
        let daysFromStart = daysFromBase(date: today)
        let xPosition = CGFloat(daysFromStart) * dayWidth
        
        currentDateLine.backgroundColor = .systemGreen
        currentDateLine.frame = CGRect(
            x: xPosition,
            y: timelineView.frame.maxY,
            width: 2,
            height: ganttBarsView.frame.height
        )
        scrollView.addSubview(currentDateLine)
    }
}

extension GanttChartViewController {
    /// Метод для добавления кнопки с тремя точками на навигационную панель.
    func setupNavigationBarForEditing() {
        // Используем системное изображение "ellipsis.circle" для кнопки
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            style: .plain,
            target: self,
            action: #selector(showEventOptions)
        )
    }
    
    /// Метод, который вызывается при тапе на кнопку. Здесь показываем UIAlertController с вариантами.
    @objc func showEventOptions() {
        // Создаем алерт с типом action sheet
        let alert = UIAlertController(title: nil, message: "Мероприятия", preferredStyle: .actionSheet)
        
        // Опция "Добавить новое мероприятие"
        let addAction = UIAlertAction(title: "Добавить новое мероприятие", style: .default) { [weak self] _ in
            // Вызываем метод для показа редактора мероприятия, передавая nil,
            // что означает – создается новое мероприятие
            self?.presentEventEditor(event: nil)
        }
        
        // Опция "Изменить существующее"
        let editAction = UIAlertAction(title: "Изменить существующее", style: .default) { [weak self] _ in
            // Для примера выбираем первое мероприятие из списка.
            // В реальном приложении можно реализовать выбор нужного мероприятия.
            if (self?.project.events.first) != nil {
                self?.presentEventSelection()
            }
        }
        
        // Кнопка отмены
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        
        // Показываем алерт
        present(alert, animated: true, completion: nil)
    }
    
    /// Метод для показа контроллера-редактора мероприятия (как для добавления, так и для редактирования).
    /// - Parameter event: Если передано значение, то происходит редактирование; если nil – добавление нового.
    func presentEventEditor(event: Event?) {
        // Создаем экземпляр контроллера редактора мероприятия
        let eventEditor = EventEditorViewController()
        eventEditor.eventToEdit = event
        
        // Замыкание, которое вызывается после сохранения мероприятия
        eventEditor.onSave = { [weak self] editedEvent in
            if let existingEvent = event {
                // Если редактируется существующее мероприятие, находим его индекс и обновляем
                if let index = self?.project.events.firstIndex(where: { $0.id == existingEvent.id }) {
                    self?.project.events[index] = editedEvent
                }
            } else {
                // Если создается новое мероприятие, добавляем его в список
                self?.project.events.append(editedEvent)
            }
            
            // Обновляем интерфейс диаграммы Ганта, удаляя старые представления и создавая новые
            self?.ganttBarsView.subviews.forEach { $0.removeFromSuperview() }
            self?.eventsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self?.createEvents()
            self?.createGanttBars()
        }
        
        // Оборачиваем контроллер в UINavigationController для отображения навигационной панели (с кнопкой "Сохранить")
        let navController = UINavigationController(rootViewController: eventEditor)
        navController.modalPresentationStyle = .pageSheet
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func presentEventSelection() {
        // Проверяем, что в проекте есть мероприятия
        guard !project.events.isEmpty else {
            let noEventsAlert = UIAlertController(title: "Ошибка", message: "Нет мероприятий для редактирования.", preferredStyle: .alert)
            noEventsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(noEventsAlert, animated: true, completion: nil)
            return
        }
        
        // Создаем новый UIAlertController для выбора мероприятия
        let selectionAlert = UIAlertController(title: "Выберите мероприятие", message: nil, preferredStyle: .actionSheet)
        
        // Добавляем для каждого мероприятия действие с его названием
        for event in project.events {
            let eventAction = UIAlertAction(title: event.title, style: .default) { [weak self] _ in
                // После выбора вызываем метод редактирования с выбранным мероприятием
                self?.presentEventEditor(event: event)
            }
            selectionAlert.addAction(eventAction)
        }
        
        // Добавляем действие отмены
        selectionAlert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(selectionAlert, animated: true, completion: nil)
    }
}
