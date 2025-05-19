import Foundation
import SwiftUI

class TimePeriodViewModel: ObservableObject {
    @Published var timePeriods: [TimePeriod] = []
    @Published var isAddingNewPeriod = false
    @Published var newStartTime = Date()
    @Published var newEndTime = Date()
    
    init() {
        loadTimePeriods()
    }
    
    func loadTimePeriods() {
        // TODO: Implement API call to load time periods
        // For now, using mock data
        timePeriods = [
            TimePeriod(startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
                      endTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!),
            TimePeriod(startTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!,
                      endTime: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!)
        ]
    }
    
    func addTimePeriod() {
        let newPeriod = TimePeriod(startTime: newStartTime, endTime: newEndTime)
        timePeriods.append(newPeriod)
        // TODO: Implement API call to save time period
        isAddingNewPeriod = false
    }
    
    func deleteTimePeriod(at indexSet: IndexSet) {
        timePeriods.remove(atOffsets: indexSet)
        // TODO: Implement API call to delete time period
    }
    
    func toggleTimePeriod(_ period: TimePeriod) {
        if let index = timePeriods.firstIndex(where: { $0.id == period.id }) {
            timePeriods[index].isActive.toggle()
            // TODO: Implement API call to update time period status
        }
    }
} 