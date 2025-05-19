import SwiftUI

struct ProfileSettingsView: View {
    @StateObject private var viewModel = ProfileSettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddTimeBlock = false
    
    var body: some View {
        List {
            Section(header: Text("High-Risk Time Periods")) {
                ForEach(viewModel.timeBlocks) { block in
                    TimeBlockRow(block: block) {
                        viewModel.removeTimeBlock(block)
                    }
                }
                
                Button(action: {
                    showingAddTimeBlock = true
                }) {
                    Label("Add Time Period", systemImage: "plus.circle.fill")
                }
            }
            
            Section(header: Text("Profile Information")) {
                NavigationLink(destination: Text("Edit Profile")) {
                    Text("Edit Profile")
                }
                
                NavigationLink(destination: Text("Notification Settings")) {
                    Text("Notification Settings")
                }
            }
        }
        .navigationTitle("Profile Settings")
        .navigationBarItems(leading: Button(action: {
            dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
        .sheet(isPresented: $showingAddTimeBlock) {
            AddTimeBlockView { startTime, endTime in
                viewModel.addTimeBlock(startTime: startTime, endTime: endTime)
            }
        }
    }
}

struct TimeBlockRow: View {
    let block: TimeBlock
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(block.startTime, style: .time)
                    .font(.headline)
                Text(block.endTime, style: .time)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

struct AddTimeBlockView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Date, Date) -> Void
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Start Time")) {
                    DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("End Time")) {
                    DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle("Add Time Period")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(startTime, endTime)
                        dismiss()
                    }
                }
            }
        }
    }
}

class ProfileSettingsViewModel: ObservableObject {
    @Published var fullName: String = ""
    @Published var username: String = ""
    @Published var timeBlocks: [TimeBlock] = []
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // TODO: Implement API call to load user settings
        // For now, using mock data
        fullName = "John Doe"
        username = "johndoe"
        timeBlocks = [
            TimeBlock(startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
                     endTime: Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!),
            TimeBlock(startTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!,
                     endTime: Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!)
        ]
    }
    
    func addTimeBlock(startTime: Date, endTime: Date) {
        let newBlock = TimeBlock(startTime: startTime, endTime: endTime)
        timeBlocks.append(newBlock)
        saveSettings()
    }
    
    func removeTimeBlock(_ block: TimeBlock) {
        timeBlocks.removeAll { $0.id == block.id }
        saveSettings()
    }
    
    func saveSettings() {
        // TODO: Implement API call to save user settings
        print("Saving settings...")
    }
}

struct TimeBlock: Identifiable {
    let id = UUID()
    let startTime: Date
    let endTime: Date
}

#Preview {
    NavigationView {
        ProfileSettingsView()
    }
} 
