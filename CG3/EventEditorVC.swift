import UIKit

/// Контроллер для редактирования или добавления мероприятия.
/// Используется в виде всплывающего снизу окна (modal presentation).
class EventEditorViewController: UIViewController {
    
    /// Если не nil, то это мероприятие редактируется; иначе – добавляется новое.
    var eventToEdit: Event?
    
    /// Замыкание, которое вызывается при сохранении. Передается новое или отредактированное мероприятие.
    var onSave: ((Event) -> Void)?
    
    // MARK: - UI Элементы
    
    let titleTextField = UITextField()
    let progressTextField = UITextField()
    let startDateTextField = UITextField()
    let endDateTextField = UITextField()
    
    // UIDatePicker для выбора дат. Теперь они будут использоваться в inline или компакт стиле,
    // чтобы выбор даты происходил непосредственно возле текстовых полей.
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Добавляем кнопку "Сохранить" в навигационную панель.
        // Чтобы она отображалась, при презентации этого контроллера необходимо использовать UINavigationController.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveEvent))
        navigationItem.title = eventToEdit == nil ? "Добавить мероприятие" : "Изменить мероприятие"
        
        // Настраиваем UI-элементы и добавляем их на экран
        setupUI()
        setupDatePickers()
        populateDataIfEditing()
    }
    
    /// Метод для настройки базового интерфейса редактора.
    /// Здесь создается вертикальный UIStackView, в который добавляются поля для ввода.
    func setupUI() {
        // Настраиваем текстовые поля с плейсхолдерами и рамками
        titleTextField.placeholder = "Название мероприятия"
        titleTextField.borderStyle = .roundedRect
        
        progressTextField.placeholder = "Прогресс (0.0 - 1.0)"
        progressTextField.borderStyle = .roundedRect
        progressTextField.keyboardType = .decimalPad
        
        startDateTextField.placeholder = "Дата начала"
        startDateTextField.borderStyle = .roundedRect
        
        endDateTextField.placeholder = "Дата окончания"
        endDateTextField.borderStyle = .roundedRect
        
        // Создаем стек для вертикального расположения элементов
        let stack = UIStackView(arrangedSubviews: [titleTextField, progressTextField, startDateTextField, endDateTextField])
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)
        
        // Устанавливаем автолейаут для стека
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    /// Метод для настройки UIDatePicker‑ов для выбора дат.
    /// Теперь вместо появления toolbar с кнопкой "Готово" мы используем inline (или compact) стиль,
    /// который позволит пользователю выбирать дату непосредственно в месте ввода.
    func setupDatePickers() {
        // Настраиваем режим работы UIDatePicker (только дата)
        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date
        
        // Если iOS 14 или новее, можно задать inline или компакт стиль,
        // чтобы UIDatePicker отображался непосредственно в поле.
        if #available(iOS 14.0, *) {
            startDatePicker.preferredDatePickerStyle = .inline
            endDatePicker.preferredDatePickerStyle = .inline
        }
        
        // Назначаем datePicker в качестве inputView для соответствующих текстовых полей.
        // Таким образом, при тапе на текстовое поле появится сам UIDatePicker (не внизу всего экрана, а привязанный к полю).
        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker
        
        // Добавляем обработчик события изменения даты, чтобы сразу обновлять текст поля при выборе даты.
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
    }
    
    /// Метод, вызываемый при изменении даты в startDatePicker.
    /// Обновляет текст в поле startDateTextField в соответствии с выбранной датой.
    @objc func startDateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        startDateTextField.text = formatter.string(from: startDatePicker.date)
    }
    
    /// Метод, вызываемый при изменении даты в endDatePicker.
    /// Обновляет текст в поле endDateTextField в соответствии с выбранной датой.
    @objc func endDateChanged() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        endDateTextField.text = formatter.string(from: endDatePicker.date)
    }
    
    /// Если редактируется существующее мероприятие, предварительно заполняем поля его данными.
    func populateDataIfEditing() {
        if let event = eventToEdit {
            titleTextField.text = event.title
            progressTextField.text = String(event.progress)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            startDateTextField.text = formatter.string(from: event.startDate)
            endDateTextField.text = formatter.string(from: event.endDate)
            startDatePicker.date = event.startDate
            endDatePicker.date = event.endDate
        }
    }
    
    /// Метод вызывается при нажатии кнопки "Сохранить" в навигационной панели.
    /// Здесь происходит валидация введенных данных, создание нового или обновленного мероприятия,
    /// и вызов замыкания onSave для передачи результата в родительский контроллер.
    @objc func saveEvent() {
        // Проверяем, что все поля заполнены корректно
        guard let title = titleTextField.text, !title.isEmpty,
              let progressText = progressTextField.text, let progress = Double(progressText),
              let startDateString = startDateTextField.text, !startDateString.isEmpty,
              let endDateString = endDateTextField.text, !endDateString.isEmpty else {
            // Если данные некорректны, показываем сообщение об ошибке
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, заполните все поля корректно.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        guard let startDate = formatter.date(from: startDateString),
              let endDate = formatter.date(from: endDateString) else {
            let alert = UIAlertController(title: "Ошибка", message: "Неверный формат даты.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Создаем новый объект Event.
        // Если редактируется существующее мероприятие, сохраняем его id, иначе генерируем новый.
        let newEvent = Event(
            id: eventToEdit?.id ?? UUID(),
            title: title,
            progress: progress,
            startDate: startDate,
            endDate: endDate,
            responsible: "Ответственный" // Здесь можно добавить дополнительное поле или выбор, если нужно.
        )
        
        // Вызываем замыкание onSave, чтобы передать созданное/обновленное мероприятие родительскому контроллеру.
        onSave?(newEvent)
        
        // Закрываем редактор
        dismiss(animated: true, completion: nil)
    }
}
