import UIKit


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
            "Александр Борщин"
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
            ),
            Event(
                id: UUID(),
                title: "Подготовка КСИО",
                progress: 0.6,
                startDate: formatter.date(from: "10.01.2024")!,
                endDate: formatter.date(from: "25.12.2024")!,
                responsible: "Снабжение")
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
