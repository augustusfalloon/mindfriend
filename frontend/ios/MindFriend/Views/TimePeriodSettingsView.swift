import SwiftUI

struct TimePeriodSettingsView: View {
    @StateObject private var viewModel = TimePeriodViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Active Time Periods")) {
                ForEach(viewModel.timePeriods) { period in
                    TimePeriodRow(period: period) {
                        viewModel.toggleTimePeriod(period)
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteTimePeriod(at: indexSet)
                }
            }
            
            Section {
                Button(action: {
                    viewModel.isAddingNewPeriod = true
                }) {
                    Label("Add Time Period", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Time Periods")
        .sheet(isPresented: $viewModel.isAddingNewPeriod) {
            NavigationView {
                Form {
                    Section(header: Text("New Time Period")) {
                        DatePicker("Start Time", selection: $viewModel.newStartTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $viewModel.newEndTime, displayedComponents: .hourAndMinute)
                    }
                }
                .navigationTitle("Add Time Period")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        viewModel.isAddingNewPeriod = false
                    },
                    trailing: Button("Add") {
                        viewModel.addTimePeriod()
                    }
                )
            }
        }
    }
}

struct TimePeriodRow: View {
    let period: TimePeriod
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(period.formattedTimeRange)
                    .font(.headline)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { period.isActive },
                set: { _ in onToggle() }
            ))
        }
    }
}

#Preview {
    NavigationView {
        TimePeriodSettingsView()
    }
} 