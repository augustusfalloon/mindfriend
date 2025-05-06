import SwiftUI
import FamilyControls
import DeviceActivity

@main
struct ScreenTimeApp: App {
  @StateObject private var model = ScreenTimeModel()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(model)
    }
  }
}

class ScreenTimeModel: ObservableObject {
  @Published var authorizationStatus: AuthorizationStatus = .notDetermined
  
  init() {
    checkAuthorizationStatus()
  }
  
  func checkAuthorizationStatus() {
    FamilyControlsCenter.shared.authorizationStatus { status in
      DispatchQueue.main.async {
        self.authorizationStatus = status
      }
    }
  }
  
  func requestAuthorization() {
    FamilyControlsCenter.shared.requestAuthorization { result in
      switch result {
      case .success:
        self.checkAuthorizationStatus()
      case .failure(let error):
        print("Authorization failed: \(error.localizedDescription)")
      }
    }
  }
}

struct ContentView: View {
    @EnvironmentObject var model: ScreenTimeModel
    @State private var isPickerPresented = false
    @State private var selectedApps = Set<ApplicationToken>()
    @State private var userId = "12345" // Replace with actual user ID

    var body: some View {
        VStack {
            if model.authorizationStatus == .approved {
                Button("Select Apps to Restrict") {
                    isPickerPresented = true
                }
                .familyActivityPicker(isPresented: $isPickerPresented, selection: $selectedApps)

                Button("Apply Restrictions") {
                    applyRestrictions()
                }
                .disabled(selectedApps.isEmpty)

                Button("Fetch Restrictions from Backend") {
                    fetchRestrictions()
                }
            } else {
                Button("Request Authorization") {
                    model.requestAuthorization()
                }
            }
        }
        .padding()
    }

    func applyRestrictions() {
        let appBundleIDs = selectedApps.map { $0.rawValue }
        let timeBlocks = ["22:00-06:00"] // Example time block

        BackendService.shared.saveRestrictions(userId: userId, restrictedApps: appBundleIDs, timeBlocks: timeBlocks) { result in
            switch result {
            case .success:
                print("Restrictions saved successfully")
            case .failure(let error):
                print("Failed to save restrictions: \(error.localizedDescription)")
            }
        }
    }

    func fetchRestrictions() {
        BackendService.shared.getRestrictions(userId: userId) { result in
            switch result {
            case .success(let data):
                print("Restricted Apps: \(data.restrictedApps)")
                print("Time Blocks: \(data.timeBlocks)")
            case .failure(let error):
                print("Failed to fetch restrictions: \(error.localizedDescription)")
            }
        }
    }
}