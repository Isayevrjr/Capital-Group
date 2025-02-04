import UIKit

class TimelineViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let timelineView = UIView()
    private var scale: CGFloat = 1.0
    private var mainEventLabels: [UILabel] = []
    private var detailedEventLabels: [UILabel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupTimeline()
        setupGestureRecognizers()
    }
    
    private func setupScrollView() {
        scrollView.frame = view.bounds
        scrollView.contentSize = CGSize(width: view.frame.width * 2, height: view.frame.height)
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        view.addSubview(scrollView)
    }
    
    private func setupTimeline() {
        let width = (scrollView.contentSize.width - 40) * 2
        let height: CGFloat = 200
        
        timelineView.frame = CGRect(x: 20, y: view.center.y - height / 2, width: width, height: height)
        timelineView.layer.cornerRadius = 10
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(timelineView)
        
        applyGradientToTimeline()
        
        NSLayoutConstraint.activate([
            timelineView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timelineView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            timelineView.widthAnchor.constraint(equalToConstant: width),
            timelineView.heightAnchor.constraint(equalToConstant: height)
        ])
        
        addMainEvents()
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
            ("Свадьба", 400, 700)
        ]
        
        for event in mainEvents {
            let label = UILabel(frame: CGRect(x: event.1, y: 60, width: event.2 - event.1, height: 80))
            label.text = event.0
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 18)
            label.textAlignment = .center
            label.backgroundColor = .red
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            timelineView.addSubview(label)
            mainEventLabels.append(label)
        }
    }
    
    private func setupGestureRecognizers() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scrollView.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            scale = max(1.0, min(scale, 3.0))
            
            UIView.animate(withDuration: 0.3) {
                self.timelineView.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
                self.scrollView.contentSize = CGSize(width: self.timelineView.frame.width * self.scale, height: self.scrollView.frame.height)
            }
            
            if scale > 2.0 {
                UIView.animate(withDuration: 0.3, animations: {
                    for label in self.mainEventLabels {
                        label.alpha = 0.0
                        label.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    }
                }) { _ in
                    self.showDetailedEvents()
                }
            } else {
                self.hideDetailedEvents()
                UIView.animate(withDuration: 0.3) {
                    for label in self.mainEventLabels {
                        label.alpha = 1.0
                        label.transform = .identity
                    }
                }
            }
            
            gesture.scale = 1.0
        }
    }
    
    private func showDetailedEvents() {
        if !detailedEventLabels.isEmpty { return }
        
        let detailedEvents: [(String, CGFloat, CGFloat)] = [
            ("Подготовка", 60, 150),
            ("Смета", 160, 250),
            ("Договоры", 260, 310),
            ("Заказ еды", 320, 350)
        ]
        
        for event in detailedEvents {
            let label = UILabel(frame: CGRect(x: event.1, y: 60, width: event.2 - event.1, height: 80))
            label.text = event.0
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textAlignment = .center
            label.backgroundColor = .yellow
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            label.alpha = 0.0
            label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            timelineView.addSubview(label)
            detailedEventLabels.append(label)
            
            UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
                label.alpha = 1.0
                label.transform = .identity
            }, completion: nil)
        }
    }
    
    private func hideDetailedEvents() {
        UIView.animate(withDuration: 0.3, animations: {
            for label in self.detailedEventLabels {
                label.alpha = 0.0
                label.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
        }) { _ in
            for label in self.detailedEventLabels {
                label.removeFromSuperview()
            }
            self.detailedEventLabels.removeAll()
        }
    }
}

extension TimelineViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return timelineView
    }
}
