import SwiftUI

struct AccountSettingsView: View {
    @EnvironmentObject var appContext: AppContext
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account Settings")) {
                    NavigationLink(destination: Text("Profile Settings")) {
                        Label("Profile", systemImage: "person.fill")
                    }
                    NavigationLink(destination: TimePeriodSettingsView()) {
                        Label("Time Periods", systemImage: "clock.fill")
                    }
                    NavigationLink(destination: Text("Notification Settings")) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    NavigationLink(destination: Text("Privacy Settings")) {
                        Label("Privacy", systemImage: "lock.fill")
                    }
                }
                
                Section {
                    Button(action: {
                        print("Logout button clicked.")
                        // Logout action
                        appContext.isLoggedIn = false
                        appContext.user = nil
                        UserDefaults.standard.removeObject(forKey: "authToken")
                        
                        // Dismiss the current view (AccountSettingsView)
                        presentationMode.wrappedValue.dismiss()
                        
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square.fill")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Account")
        }
    }
}
