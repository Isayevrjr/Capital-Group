import UIKit

// MARK: - Модели 
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

