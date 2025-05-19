import Foundation

struct TimePeriod: Identifiable, Codable {
    let id: UUID
    var startTime: Date
    var endTime: Date
    var isActive: Bool
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date, isActive: Bool = true) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.isActive = isActive
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
} 