import UIKit

class TimelineViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let timelineView = UIView()
    private var mainEventLabels: [UILabel] = []
    private var detailedEventLabels: [UILabel] = []
    private var dateLabels: [UILabel] = []
    private var isDetailViewVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupTimeline()
        setupGestureRecognizers()
    }
    
    private func setupGestureRecognizers() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width * 3, height: view.frame.height)
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceHorizontal = true
        view.addSubview(scrollView)
    }
    
    private func setupTimeline() {
        let width = scrollView.contentSize.width * 1.5
        let height: CGFloat = 200
        
        timelineView.frame = CGRect(x: 0, y: view.center.y - height / 2, width: width, height: height)
        timelineView.layer.cornerRadius = 10
        scrollView.addSubview(timelineView)
        
        applyGradientToTimeline()
        addMainEvents()
        addDateLabels(forDetailedView: false)
    }
    
    private func applyGradientToTimeline() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = timelineView.bounds
        gradientLayer.colors = [
            UIColor.white.cgColor,
            UIColor.lightGray.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        timelineView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func addMainEvents() {
        let mainEvents: [(String, CGFloat, CGFloat)] = [
            ("Концерт", 50, 350),
            ("Свадьба", 400, 700),
            ("Конференция", 750, 1050),
            ("Выставка", 1100, 1400)
        ]
        
        for event in mainEvents {
            let label = UILabel(frame: CGRect(x: event.1, y: 60, width: event.2 - event.1, height: 80))
            label.text = event.0
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.textAlignment = .center
            label.backgroundColor = .gray
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.isUserInteractionEnabled = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleEventTap(_:)))
            label.addGestureRecognizer(tapGesture)
            
            timelineView.addSubview(label)
            mainEventLabels.append(label)
        }
    }
    
    private func addDateLabels(forDetailedView: Bool) {
        for label in dateLabels {
            label.removeFromSuperview()
        }
        dateLabels.removeAll()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let interval = forDetailedView ? 7 : 30
        let count = forDetailedView ? 12 : 6
        
        var xOffset: CGFloat = 50
        for i in 0..<count {
            let date = Calendar.current.date(byAdding: .day, value: i * interval, to: startDate)!
            let label = UILabel(frame: CGRect(x: xOffset, y: 180, width: 100, height: 20))
            label.text = dateFormatter.string(from: date)
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 14)
            label.textAlignment = .center
            timelineView.addSubview(label)
            dateLabels.append(label)
            xOffset += 150
        }
    }
    
    @objc private func handleEventTap(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel else { return }
        
        if !isDetailViewVisible {
            for eventLabel in mainEventLabels {
                eventLabel.alpha = 0.0
            }
            showDetailedEvents(for: label)
            addDateLabels(forDetailedView: true)
            isDetailViewVisible = true
        }
    }
    
    private func showDetailedEvents(for mainEvent: UILabel) {
        let detailedEvents: [(String, CGFloat, CGFloat)] = [
            ("Подготовка", 60, 150),
            ("Смета", 160, 250),
            ("Договоры", 260, 310),
            ("Заказ еды", 320, 350),
            ("Тестовый этап", 360, 410)
        ]
        
        for event in detailedEvents {
            let label = UILabel(frame: CGRect(x: event.1, y: mainEvent.frame.maxY + 10, width: event.2 - event.1, height: 50))
            label.text = event.0
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textAlignment = .center
            label.backgroundColor = .yellow
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.alpha = 0.0
            
            timelineView.addSubview(label)
            detailedEventLabels.append(label)
            
            UIView.animate(withDuration: 0.4, animations: {
                label.alpha = 1.0
            })
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if isDetailViewVisible {
            hideDetailedEvents()
            addDateLabels(forDetailedView: false)
            for eventLabel in mainEventLabels {
                eventLabel.alpha = 1.0
            }
            isDetailViewVisible = false
        }
    }
    
    private func hideDetailedEvents() {
        for label in self.detailedEventLabels {
            label.removeFromSuperview()
        }
        self.detailedEventLabels.removeAll()
    }
}
