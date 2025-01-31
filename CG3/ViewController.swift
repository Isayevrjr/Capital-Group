import UIKit

// MARK: - Модели данных
struct Project {
    let id: UUID
    var title: String
    var manager: String
    var events: [Event]
}

struct Event {
    let id: UUID
    var title: String
    var progress: Double
    var startDate: Date
    var endDate: Date
    var responsible: String
}

// MARK: - Главный экран с коллекцией
class ProjectListViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var projects: [Project] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupCollectionView()
        setupNavigationBar()
    }
    
    private func setupData() {
        let managers = [
            "Игорь Барабанщиков",
            "Игорь Штахура",
            "Борщин Александр"
        ]
        
        projects = [
            Project(
                id: UUID(),
                title: "Сити-2",
                manager: managers[0],
                events: generateEvents()
            ),
            Project(
                id: UUID(),
                title: "МАИ",
                manager: managers[0],
                events: generateEvents()
            ),
            Project(
                id: UUID(),
                title: "Корты-2",
                manager: managers[0],
                events: generateEvents()
            ),
            Project(
                id: UUID(),
                title: "Вешние воды",
                manager: managers[1],
                events: generateEvents()
            ),
            Project(
                id: UUID(),
                title: "МГСУ ЖК",
                manager: managers[1],
                events: generateEvents()
            ),
            Project(
                id: UUID(),
                title: "МИГ",
                manager: managers[2],
                events: generateEvents()
            )
        ]
    }
    
    private func generateEvents() -> [Event] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        
        return [
            Event(
                id: UUID(),
                title: "Подготовка документации",
                progress: 0.8,
                startDate: formatter.date(from: "01.01.2024")!,
                endDate: formatter.date(from: "15.01.2024")!,
                responsible: "Инженер"
            ),
            Event(
                id: UUID(),
                title: "Закупка материалов",
                progress: 0.4,
                startDate: formatter.date(from: "10.01.2024")!,
                endDate: formatter.date(from: "25.01.2024")!,
                responsible: "Снабжение"
            )
        ]
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width - 32, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(ProjectCell.self, forCellWithReuseIdentifier: ProjectCell.reuseID)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Проекты"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Коллекция проектов
extension ProjectListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        projects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCell.reuseID, for: indexPath) as! ProjectCell
        cell.configure(with: projects[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = GanttChartViewController()
        vc.project = projects[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Ячейка проекта
class ProjectCell: UICollectionViewCell {
    static let reuseID = "ProjectCell"
    
    private let container = UIView()
    private let titleLabel = UILabel()
    private let managerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with project: Project) {
        titleLabel.text = project.title
        managerLabel.text = project.manager
    }
    
    private func setupViews() {
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.1
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        managerLabel.font = .systemFont(ofSize: 14)
        managerLabel.textColor = .secondaryLabel
        
        contentView.addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(managerLabel)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        managerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            managerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            managerLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            managerLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            managerLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Диаграмма Ганта
class GanttChartViewController: UIViewController {
    var project: Project!
    
    private let scrollView = UIScrollView()
    private let timelineView = UIView()
    private let eventsStack = UIStackView()
    private let ganttBarsView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = project.title
        setupViews()
        createTimeline()
        createEvents()
        createGanttBars()
    }
    
    private func setupViews() {
        scrollView.contentSize = CGSize(width: 2000, height: 600)
        scrollView.showsHorizontalScrollIndicator = false
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        timelineView.backgroundColor = .systemGray5
        scrollView.addSubview(timelineView)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timelineView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            timelineView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            timelineView.widthAnchor.constraint(equalToConstant: 2000),
            timelineView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        eventsStack.axis = .vertical
        scrollView.addSubview(eventsStack)
        eventsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            eventsStack.topAnchor.constraint(equalTo: timelineView.bottomAnchor, constant: 16),
            eventsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            eventsStack.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        scrollView.addSubview(ganttBarsView)
        ganttBarsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            ganttBarsView.topAnchor.constraint(equalTo: timelineView.bottomAnchor, constant: 16),
            ganttBarsView.leadingAnchor.constraint(equalTo: eventsStack.trailingAnchor, constant: 16),
            ganttBarsView.heightAnchor.constraint(equalToConstant: 500),
            ganttBarsView.widthAnchor.constraint(equalToConstant: 2000)
        ])
    }
    
    private func createTimeline() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let endDate = Calendar.current.date(byAdding: .month, value: 2, to: Date())!
        
        var currentX: CGFloat = 0
        var currentDate = startDate
        
        while currentDate <= endDate {
            let label = UILabel()
            label.text = formatter.string(from: currentDate)
            label.font = .systemFont(ofSize: 10)
            label.frame = CGRect(x: currentX, y: 20, width: 60, height: 20)
            timelineView.addSubview(label)
            
            currentX += 60
            currentDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
        }
    }
    
    private func createEvents() {
        project.events.enumerated().forEach { index, event in
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 4
            
            let titleLabel = UILabel()
            titleLabel.text = event.title
            titleLabel.font = .systemFont(ofSize: 14)
            
            let progressLabel = UILabel()
            progressLabel.text = "\(Int(event.progress * 100))%"
            progressLabel.textColor = .systemBlue
            progressLabel.font = .systemFont(ofSize: 12)
            
            stack.addArrangedSubview(titleLabel)
            stack.addArrangedSubview(progressLabel)
            
            stack.frame = CGRect(x: 0, y: CGFloat(index * 60), width: 200, height: 50)
            eventsStack.addArrangedSubview(stack)
        }
    }
    
    private func createGanttBars() {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let baseDate = dateFormatter.date(from: "01.01.2024")!
        let dayWidth: CGFloat = 10
        
        project.events.enumerated().forEach { index, event in
            let yPosition = CGFloat(index * 60 + 20)
            
            // Плановая полоса
            let planBar = UIView()
            planBar.backgroundColor = .systemGray5
            planBar.layer.cornerRadius = 4
            let startDays = calendar.dateComponents([.day], from: baseDate, to: event.startDate).day!
            let durationDays = calendar.dateComponents([.day], from: event.startDate, to: event.endDate).day!
            planBar.frame = CGRect(
                x: CGFloat(startDays) * dayWidth,
                y: yPosition,
                width: CGFloat(durationDays) * dayWidth,
                height: 20
            )
            ganttBarsView.addSubview(planBar)
            
            // Прогресс
            let progressBar = UIView()
            progressBar.backgroundColor = .systemBlue
            progressBar.layer.cornerRadius = 4
            let progressWidth = CGFloat(durationDays) * dayWidth * CGFloat(event.progress)
            progressBar.frame = CGRect(
                x: CGFloat(startDays) * dayWidth,
                y: yPosition,
                width: progressWidth,
                height: 20
            )
            ganttBarsView.addSubview(progressBar)
        }
    }
}
